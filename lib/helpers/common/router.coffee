ironRouter = Router
ironRouteController = RouteController

class @Helpers.Router

    currentLayout = null
    currentRouteName = null
    currentParams = null
    beforeActionRouteName = null
    actionInitialised = new ReactiveVar()
    firstLayoutSet = false

    @Routes: {}
    @CurrentTitle: null

    SESSION_KEY_TRACKING = 'UtmTrackingInfo'


    @GetCurrentParams: => # For some reason, magically sometimes @route.params is empty when it shouldn't (e.g. search id). This fixes the issue
        currentParams

    @GetCurrentRouteProperties: =>
        @GetRouteProperties ironRouter.current()?.route?.getName()

    @GetRouteProperties: (name) =>
        name = Helpers.Translation.CleanRouteName name
        @Routes[name]

    setBodyLayout = (layout, route) ->
        body = $ document.body

        routeProperties = Router.GetRouteProperties route.getName() || {}

        removeBodyClass = ->
            if body.attr 'data-layout-class'
                body.removeClass body.attr 'data-layout-class'

            classes = layout || ''

            # adding current mapping
            classes += ' ' + Helpers.Translation.CleanRouteName(route.getName()).replace(/\./g, '-')

            classes += ' ' + routeProperties.extraBodyClass if routeProperties.extraBodyClass

            # adding current roles
            for role in Roles.getRolesForUser Meteor.userId()
                classes += ' ' + 'role-' + role

            body.addClass classes
            body.attr 'data-layout-class', classes

        if (body.attr('class') || '').indexOf('transitioning') > -1
            Meteor.setTimeout removeBodyClass, 250
        else
            removeBodyClass()

    # Query String Management
    @AddParameter = (url, name, value) =>

        if not url
            return url

        if url.indexOf('?') > -1
            url += '&'
        else
            url += '?'

        url += name + '=' + encodeURIComponent(value)

        return url

    urlQueryString = null
    lastQueryString = null

    getQueryString = ->
        if history.pushState
            query  = window.location.search.substring(1);
        else
            query  = window.location.hash
            if query.length > 2
                queryStart = query.indexOf '?'
                if queryStart > -1 and queryStart < query.length - 2
                    query = query.substr queryStart + 1
                else
                    query = ''

        query

    updateQueryString = (state) ->
        pl = /\+/g
        search = /([^&=]+)=?([^&]*)/g
        decode = (s) ->
            return decodeURIComponent(s.replace(pl, " "))

        lastQueryString = getQueryString()

        urlQueryString = {}

        while (match = search.exec(lastQueryString))
            urlQueryString[decode(match[1])] = decode(match[2])

    @GetQueryString = =>
        if lastQueryString isnt getQueryString()
            updateQueryString()

        _.extend {}, urlQueryString

    @GetUtmInfo = =>
        q = @GetQueryString()

        r = {}
        r.source = q.utm_source if q.utm_source
        r.campaign = q.utm_campaign if q.utm_campaign
        r.medium = q.utm_medium if q.utm_medium
        r.term = q.utm_term if q.utm_term
        r.content = q.utm_content if q.utm_content

        r

    @SetStoredUtmInfo: (info) =>
        if not info?.source
            info = @GetUtmInfo()

        Helpers.Client.Storage.Set SESSION_KEY_TRACKING, info

    @GetStoredUtmInfo: =>
        utmInfoFromUrl = @GetUtmInfo()
        utmInfoFromStorage = Helpers.Client.Storage.Get(SESSION_KEY_TRACKING)

        if not _.isEmpty(utmInfoFromUrl)
            @SetStoredUtmInfo(utmInfoFromUrl)
            utmInfoFromStorage = utmInfoFromUrl

        return utmInfoFromStorage

    if Meteor.isClient
        updateQueryString()
        window.onpopstate = updateQueryString
        window.onhashchange = updateQueryString

    # Iron Router Management
    @Path: (route, params, options= {}) =>

        if typeof route is 'string' and ironRouter.routes[route]
            route = ironRouter.routes[route]

        # Ensuring query string is always an object and persisting UTM params
        options.query ||= {}

        try
            if typeof options.query is 'string'
                queryParams = options.query.split '&'
                for param in queryParams
                    paramParts = param.split '='
                    options.query[paramParts[0]] = paramParts[1] if paramParts.length is 2

            queryString = Helpers.Router.GetQueryString()

            for own key, value of queryString
                if key.toLowerCase().indexOf('utm_') is 0
                    options.query[key] = value
        catch e
            console.log e

        if not route?.path
            return route

        path = route.path params, options

        if Meteor.isClient
            if Helpers.Client.Auth.IsSpoofing()
                path = @AddParameter path, 'spoofing', 'true'
                path = @AddParameter path, 'spoof', @GetQueryString().spoof
        path

    ironRouter.Path = @Path

    _ironRouterGo = ironRouter.go
    ironRouter.go = (route, params, options = {}) ->
        path = route

        # Ensuring proper routing by path or route
        if ironRouter.routes[route]
            path = Router.Path route, params, options
        _ironRouterGo.call @, path

    @AddRoute: (route) =>

        if @Routes[route.name]
            throw 'There is already a route for ' + route.name

        @Routes[route.name] = route

    @SetRoute: (originalRoute) =>

        if not originalRoute.title
            originalRoute.title = =>
                return translate(originalRoute.name + '.title')

        for language in ServerSettings.languages

            route = _.extend {}, originalRoute

            path = '/' + route.path
            title = route.title
            description = route.description
            image = route.image
            Object.deleteProperty route, 'title'
            Object.deleteProperty route, 'description'
            Object.deleteProperty route, 'image'
            Object.deleteProperty route, 'path'

            if language isnt ServerSettings.defaultLanguage
                path = '/' + language + path
                route.name = language + '_' + route.name

            #if not route.bypassFastRender
                #route.fastRender = true

            route.language = language

            action = route.action

            _waitOn = route.waitOn
            route.waitOn = ->
                Helpers.Log.Tick(route.name + ' WO')
                retVal = if _waitOn then _waitOn.apply(@, arguments) else []

                # Common translations loaded here for fast render
                language = Helpers.Translation.GetUserLanguage(@path)

                if not commonsTranslationsLoaded
                    Translation.cacheSubscribe retVal, [language], 'common_translations_' + language, 'common_translations'
                    commonsTranslationsLoaded = true

                retVal.push subManager.subscribe('translations', language, originalRoute.name)
                retVal

            _onBeforeAction = route.onBeforeAction
            route.onBeforeAction = ->

                Helpers.Log.Tick(route.name + ' OBA')

                currentRoute = @route.getName()

                if beforeActionRouteName != currentRoute
                    beforeActionRouteName = currentRoute
                    actionInitialised.set false
                    Helpers.Log.Info 'Setting action as uninitialised for: ' + currentRoute

                if _onBeforeAction
                    return _onBeforeAction.apply @, arguments

                @next()

            _onAfterAction = route.onAfterAction
            route.onAfterAction = ->
                Helpers.Log.Tick(route.name + ' OAA')
                Helpers.Log.Info 'Ready for Spiderable'
                Meteor.setTimeout ->
                    Meteor.isReadyForSpiderable = true
                , 100
                if @ready()
                    if _onAfterAction
                        return _onAfterAction.apply @

            route.action = ->
                Helpers.Log.Tick(route.name + ' OA')

                loading = true

                # Separating action execution and initialisation as apparently the initialisation steps get the action to re-run
                if @ready()

                    Helpers.Log.Tick(route.name + ' OA ready')

                    Helpers.Translation.ReloadPageTranslations()

                    if actionInitialised.get()

                        @layout route.controller.layout
                        Helpers.Log.Info 'Action rendered: ' + @route.getName()
                        loading = false

                        currentParams = @params

                        return action.apply @
                    else

                        Helpers.Translation.ReloadPageTranslations()

                        Router.CurrentTitle = title.apply @
                        Router.CurrentDescription = description.apply(@) if description
                        Router.CurrentImage = image.apply(@) if image

                        Helpers.Client.SEO.SetTitle Router.CurrentTitle
                        Helpers.Client.SEO.SetDescription(Router.CurrentDescription) if Router.CurrentDescription
                        Helpers.Client.SEO.SetImage(Router.CurrentImage) if Router.CurrentImage

                        actionInitialised.set true

                if loading
                    @layout 'loader'
                    @render 'loading'

            ironRouter.route path, route

    @SetCurrentRouteName: (value) =>
        currentRouteName = value

    @GetCurrentRouteName: ->
        if @route
            return @route

        return currentRouteName

    @AddController: (controller) =>

        layout = controller.layoutTemplate
        parentController = controller.extends || ironRouteController
        bodyClass = controller.bodyClass || parentController.bodyClass
        Object.deleteProperty controller, 'parentController'
        Object.deleteProperty controller, 'layoutTemplate'

        if Meteor.isClient

            _onAfterAction = controller.onAfterAction
            _onBeforeAction = controller.onBeforeAction

            controller.onBeforeAction = ->
                Helpers.Log.Tick(controller.name + ' OBA')
                if _onBeforeAction
                    _onBeforeAction.apply @, arguments
                else
                    @next()

            controller.onAfterAction = ->
                Helpers.Log.Tick(controller.name + ' OAA')
                if not firstLayoutSet
                    setBodyLayout bodyClass, @route
                    firstLayoutSet = true

                if @ready()
                    Helpers.Log.Tick(controller.name + ' OAA ready')
                    Meteor.setTimeout =>
                        setBodyLayout bodyClass, @route
                    , 10

                    if _onAfterAction
                        _onAfterAction.apply @, arguments

        ret = parentController.extend controller

        ret.bodyClass = bodyClass
        ret.layout = layout
        ret

    @Init: =>
        for own key, value of @Routes
            @SetRoute value

    @HardGo = (route, path, options) ->

        destination = Router.Path route, path, options

        if destination.indexOf('?') > -1
            destination += '&'
        else
            destination += '?'

        destination += 'langRedirect=true'

        location.href = destination
