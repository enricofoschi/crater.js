class @Helpers.Client.Auth


    SESSION_LOGIN_WITH_EXTERNAL_TRIGGERED = 'LgnWthExtrnl'

    @SetAsLoggedIn: (properties, callback) ->

        Helpers.Client.Loader.Show true

        currentUserId = Meteor.userId()
        targetUserId = properties.userId
        loginChecker = null

        _callback = callback
        callback = ->
            Helpers.Client.Loader.Hide true
            if _callback
                _callback()
            if loginChecker
                loginChecker.stop()

        if currentUserId is targetUserId
            callback()
            return
        else
            loginChecker = Tracker.autorun =>
                if Meteor.userId() is targetUserId
                    callback()

        Helpers.Log.Info 'Setting new user:'
        Helpers.Log.Info arguments

        Helpers.Client.Storage.SetNative 'Meteor.loginToken', properties.token
        Helpers.Client.Storage.SetNative 'Meteor.loginTokenExpires', properties.expires
        Helpers.Client.Storage.SetNative 'Meteor.userId', properties.userId

        # Get Back functionality
        Helpers.Client.Storage.SetNative 'Meteor.getBackToken', properties.getBackToken
        Helpers.Client.Storage.SetNative 'Meteor.getBackUserId', properties.getBackUserId
        Helpers.Client.Storage.SetNative 'Meteor.getBackUserName', properties.getBackUserName

        Meteor.default_connection.setUserId(properties.userId)
        Helpers.Client.SessionHelper.EnsureToken()

    @GetSpoofingUrl: (user) ->
        url = null

        if ServerSettings.urls.frontend
            url = ServerSettings.urls.frontend
        else
            url = '/'

        url = Helpers.Router.AddParameter url, 'spoofing', 'true'
        url = Helpers.Router.AddParameter url, 'spoof', user._id

    @IsSpoofing: ->
        Helpers.Router.GetQueryString().spoofing is 'true'

    @GetSpooferName: ->
        spooferName = Helpers.Client.Storage.GetNative 'Meteor.getBackUserName'

        if spooferName and spooferName isnt 'undefined'
            return spooferName

        return null

    @SetSpooferBack: (callback) =>
        token = Helpers.Client.Storage.GetNative 'Meteor.getBackToken'
        userId = Helpers.Client.Storage.GetNative 'Meteor.getBackUserId'
        expires = (new Date()).addDays(60)

        @SetAsLoggedIn {
            token: token
            expires: expires
            userId: userId
        }, callback

    @HasTriedToLogInExternally: (flushIfLoggedIn) =>
        return false if not Meteor.userId()

        r = Helpers.Client.SessionHelper.Get SESSION_LOGIN_WITH_EXTERNAL_TRIGGERED
        
        if flushIfLoggedIn
            Helpers.Client.SessionHelper.Set SESSION_LOGIN_WITH_EXTERNAL_TRIGGERED, null

        return r

    @LoginWith: (service, callback) =>
        method = Meteor['loginWith' + service]
        properties = {}

        properties.loginStyle = 'popup'

        if IsMobile
            properties.loginStyle = 'redirect'

        if service.toLowerCase() is 'facebook'
            properties.requestPermissions = [
                'email'
                'public_profile'
            ]

        if not Meteor.userId()
            Helpers.Client.SessionHelper.Set SESSION_LOGIN_WITH_EXTERNAL_TRIGGERED, true

        method properties, (e, r) =>
            if e
                if e.message?.indexOf('No matching login') > -1
                    return
                if e.message?.indexOf('403') is -1
                    Router.go 'presentation.signup'
            else
                Helpers.Log.Info 'Logged in with ' + service
                Feature_Users.Helpers.OnLogin(->
                    callback.apply(@, arguments) if callback
                )

    @UntilNextUserRefresh: (callback) ->
        initialised = false

        tracker = Tracker.autorun ->
            if initialised
                callback()
                tracker.stop()

            Meteor.user() # subscribing
            initialised = true

    # Not handled as base controller mainly because of performance reasons
    @SetLoggedInPath: null

    @GetLoggedInPath: =>

        if @SetLoggedInPath
            path = @SetLoggedInPath()

        path || Helpers.Router.Path('default')



    @OnLoggedInRedirect: =>
        Router.go @GetLoggedInPath()