class @Helpers.Analytics

    lastTrackedUrl = null
    lastIdentity = null
    isLoggedOut = true
    userStatusInitialized = false

    DEFAULT_TRACKERS = [
        'Errorception'
        'Google Analytics'
        'Intercom'
        'KISSmetrics'
    ]

    isAdmin = ->
        try
            if ServerSettings.admin
                return true
            else if MeteorUser.GetCurrentUser().hasRole('admin')
                return true
        catch e

        return false

    @CanTrack: =>

        try
            if Meteor.isClient and Helpers.Client.Auth.IsSpoofing()
                return false

            if ServerSettings['segment.io']?.disable
                return false

            if Meteor.isClient and Session.get('___isPhantomjs___')
                callback null, null

            if isAdmin()
                return false

            return true
        catch e
            if ServerSettings.debug
                Helpers.Log.Error e
            return true


    @Init: =>

        if not @CanTrack()
            return false

        analytics.load(ServerSettings['segment.io']?.key) if analytics

        Tracker.autorun =>
            @Identify()

    @Identify: =>
        try
            if not @CanTrack()
                return false

            user = MeteorUser.GetCurrentUser()

            if user._id and user._id isnt lastIdentity

                traits = user.getTrackingTraits()

                if userStatusInitialized # we only track it on change

                    signupTracked = user.platform?.signup_tracked

                    @ServerSideIdentify()
                    if analytics
                        analytics.identify user._id, traits, =>
                            if not signupTracked
                                @TrackSignUp()
                            else
                                @TrackLogin()
                    else
                        if not signupTracked
                            @TrackSignUp()
                        else
                            @TrackLogin()

                    if window.mixpanel
                        if not signupTracked
                            mixpanel.alias Meteor.userId()
                        else
                            mixpanel.identify Meteor.userId()
                        mixpanel.people.set traits

                else
                    @ServerSideIdentify()
                    analytics.identify(user._id, traits) if analytics

                lastIdentity = user._id

            userStatusInitialized = true
        catch e
            if ServerSettings.debug
                throw e


    @TrackPage: (pageName) =>
        if not @CanTrack()
            return false

        if Meteor.userId()
            @Identify()

        Helpers.Log.Info 'Tracking page'

        try
            if lastTrackedUrl isnt location.href

                trackingProperties = {
                    location: location.href
                    page: pageName
                }

                # Client Side Tracking
                if analytics
                    if pageName then analytics.page(pageName, trackingProperties) else analytics.page(trackingProperties)
                lastTrackedUrl = location.href

                if @HasMixpanel()
                    mixpanel.track 'Page View', trackingProperties

                # Server Side Tracking
                @ServerSideTrack 'Page View', {
                    page: pageName
                    location: location.href
                }

        catch e
            if ServerSettings.debug
                throw e

    @ServerSideIdentify: =>
        Helpers.Client.MeteorHelper.CallMethod {
            background: true
            method: 'tracking.identify'
            params: [
                Helpers.Translation.GetUserLanguage()
            ]
        }

    @ServerSideTrack: (event, properties) =>
        utmInfo = Helpers.Client.Auth.GetUtmInfo()
        properties.utm_info = utmInfo if utmInfo

        Helpers.Client.MeteorHelper.CallMethod {
            background: true
            method: 'tracking.track'
            params: [
                event
                properties
            ]
            callback: (error, result) ->
                if result
                    Helpers.Client.SessionHelper.ParseClientData result
        }

    @HasMixpanel: =>
        window.mixpanel

    @Track: (event, properties, callback) =>

        if not @CanTrack()
            return false

        properties ||= {}

        try
            @ServerSideTrack event, properties
            analytics.track(event, properties, callback) if analytics

            if @HasMixpanel()
                mixpanel.track event, properties
        catch e

    @TrackLogin: =>
        @Track 'Logged In'

    @TrackLogout: =>
        @Track 'Logged Out', {}, ->
            analytics.reset() if analytics

        # To ensure we don't have a racing conditions between logging
        Meteor.setTimeout ->
            isLoggedOut = false
        , 250

    @TrackSignUp: =>

        Helpers.Translation.GetUserLanguage() # also needed to SET the user language on intercom

        @Track 'Signed Up', {
            roles: Roles.getRolesForUser(Meteor.userId()).join(',')
        }

        utmInfo = Helpers.Client.Auth.GetUtmInfo()

        if Object.keys(utmInfo).length
            Helpers.Client.MeteorHelper.CallMethod {
                method: 'users.setUTMTrackingInfo'
                background: true
                params: [
                    utmInfo
                ]
            }

        Helpers.Client.MeteorHelper.CallMethod {
            method: 'users.signupTracked'
            background: true
        }

        if Meteor.isClient and not ServerSettings.debug
            @TrackAdwordsConversion 990844894, 'VdYsCIaw618Q3q-82AM'
            @TrackFacebookConversion '6029349662010'

    @TrackFacebookConversion: (id) =>
        try
            _fbq = window._fbq or (window._fbq = [])
            if !_fbq.loaded
                script = $ '<script></script>'
                script.attr 'src', '//connect.facebook.net/en_US/fbds.js'
                $('head').append script
                _fbq.loaded = true

            window._fbq = window._fbq or []
            window._fbq.push [
                'track'
                id
                {
                    'value': '0.00'
                    'currency': 'EUR'
                }
            ]
        catch e



    @TrackAdwordsConversion: (id, label) =>
        try
            Helpers.Client.DOM.LoadJS {
                identifier: 'adwords'
                url: 'https://www.googleadservices.com/pagead/conversion_async.js'
                callback: ->
                    goog_snippet_vars = ->
                        Helpers.Log.Info 'Tracking conversion: ' + id + ', ' + label
                        w = window
                        w.google_conversion_id = id
                        w.google_conversion_label = label
                        w.google_remarketing_only = false

                    goog_report_conversion = (url) ->
                        goog_snippet_vars()
                        window.google_conversion_format = "3"
                        window.google_is_call = true
                        opt = new Object()
                        opt.onload_callback = ->
                            if url
                                window.location = url

                        conv_handler = window['google_trackConversion']
                        if typeof(conv_handler) is 'function'
                            conv_handler(opt);

                    goog_report_conversion()
            }
        catch e
            Helpers.Log.Error e

if Meteor.isServer

    intercom = null
    intercomClient = null

    class @Helpers.Analytics
        @GetIntercomClient: ->
            if not intercom
                intercom = Meteor.npmRequire 'intercom-client'
                intercomClient = new intercom.Client Meteor.settings.intercom.appId, Meteor.settings.intercom.appKey
            intercomClient

