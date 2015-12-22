globalContext = @

class @Helpers.Translation

    translator = null
    translations = {}
    serverTranslations = null
    routeLoaded = null
    commonTranslationsLoaded = false
    commonTranslations = []
    commonTranslationsLoadedCallbacks = []
    languageSet = null

    # using this variable to record the last time we set a user lang - so that if we trigger 1000 times GetUserLanguage, we won't trigger 1000 times the method call to set the user lang
    lastUserLanguageSet = null

    @LANGUAGE_KEY: 'session_lang'
    @LANGUAGE_FORCED_KEY: 'session_lang_forced'

    @Reset: =>
        lastUserLanguageSet = null

    @OnCommonTranslationsLoaded: (callback) =>
        commonTranslationsLoadedCallbacks.push callback

    @ExecuteCommonTranslationsLoadedCallbacks: =>
        for callback in commonTranslationsLoadedCallbacks
            callback()

        commonTranslationsLoadedCallbacks = []

    @ReloadPageTranslations: ->
        routeLoaded = null
        @Init()

    loadTranslations = (filters) =>

        filters ||= {}
        if not filters.lang
            filters.lang = @GetUserLanguage()

        translationData = globalContext.Translation.where filters
        Helpers.Log.Info 'Translations: ' + translationData.length
        addTranslations translationData

        translationData

    addTranslations = (translationData) =>
        for translation in translationData
            translations[translation.key] = translation.value || ''

    @ResetServerTranslations: ->
        serverTranslations = null

    @Init: ->

        if Meteor.isServer
            if not serverTranslations?['en'] or not serverTranslations?['de']
                serverTranslations = {}
                data = globalContext.Translation.all()

                for t in data
                    serverTranslations[t.lang] = {} if not serverTranslations[t.lang]
                    serverTranslations[t.lang][t.key] = t.value
        else
            if globalContext.Translation

                if Meteor.isClient
                    lang = Translation.GetUserLanguage()

                    if not commonTranslationsLoaded
                        commonTranslations = _.filter(globalContext.Translation.allCached('common_translations_' + lang), (t)  -> t.common)
                        translationsData = addTranslations commonTranslations

                        if translationsData.length
                            commonTranslationsLoaded = true

                            # Caching Global Translations
                            commonTranslations = _.extend {}, translations

                            Helpers.Log.Info 'Global Translations Loaded'

                            Translation.ExecuteCommonTranslationsLoadedCallbacks()

                    # Route translations
                    route = Helpers.Router.GetCurrentRouteName.apply @

                    if route isnt routeLoaded and route
                        translations = _.extend {}, commonTranslations

                        translationsData = loadTranslations {
                            common:
                                $ne: true
                        }

                        if translationsData.length
                            Helpers.Log.Info 'Route Translations Loaded for ' + route
                            routeLoaded = route

                else if Meteor.isServer
                    if not translations
                        loadTranslations {}
                        Helpers.Log.Info 'All translations loaded'

    @Translate: (key, placeholders, forcedLang) =>

        # handle plurals
        if placeholders and placeholders.count is 0
            key += '_none'
        if placeholders and (placeholders.count and placeholders.count isnt 1)
            key += '_plural'

        translation = null

        if Meteor.isServer
            @Init()

            lang = forcedLang || @GetUserLanguage()
            if serverTranslations?[lang]

                translation = serverTranslations[lang]?[key]

                if not translation
                    translatorService = Crater.Services.Get Services.TRANSLATOR
                    translatorService.addEmptyTranslation key, Router.current?()?.route?.getName()
            else
                translation = ''
        else
            if not translations[key] and translations[key] isnt ''
                Helpers.Log.Info 'Missing key ' + key

                routeParams = null

                if Router.current?()?.params
                    routeParams = {}

                    for own objKey, value of Router.current().params when objKey isnt 'query' and objKey isnt 'hash'
                        routeParams[objKey] = value

                Helpers.Client.MeteorHelper.CallMethod {
                    method: 'addEmptyTranslation'
                    background: true
                    params: [
                        key
                        Router.current?()?.route?.getName()
                        routeParams
                    ]
                }

            if ServerSettings.debug
                translation = translations[key] || "%#{key}%"
            else
                translation = translations[key] || key.split('.').pop()

        if placeholders
            return translation.format placeholders
        else
            return translation

    @GetPriceDelimiter: =>
        ServerSettings.localization[Helpers.Translation.GetUserLanguage()].priceDelimiter

    @GetLanguageByPath: (locationPath) =>
        if locationPath.length > 2
            langPath = (locationPath.substr(1, if locationPath.length is 3 then 2 else 3)).toLowerCase()


            if langPath[langPath.length - 1] is '/'
                langPath = langPath.substr(0, langPath.length - 1)

            lang = langPath.toString()

            if lang in ServerSettings.languages
                return lang

        return ServerSettings.defaultLanguage.toString()


    @GetUserLanguage: (path) =>

        if Meteor.isClient

            query = Helpers.Router.GetQueryString()

            sessionLang = Helpers.Client.SessionHelper.Get @LANGUAGE_KEY
            retVal = null
            user = null
            currentRoute = Router.current()
            currentRouteName = Router.current()?.route?.getName()
            spoofing = Helpers.Client.Auth.IsSpoofing()
            forcing = query.setLanguage is 'true' and not spoofing
            phantom = query.___isRunningPhantomJS___ is 'true'

            # Giving priority to route
            if currentRouteName
                retVal = @GetLanguageByRoute currentRouteName

            if not retVal
                # Then giving priority to the browser language
                locationPath = location.pathname
                if not history.pushState
                    locationPath = location.hash

                if locationPath.indexOf('#!') is 0 and locationPath.length > 2
                    locationPath = '/' + locationPath.substring 2

                retVal = @GetLanguageByPath locationPath

            # storing in the session
            if retVal isnt sessionLang and retVal isnt languageSet and Crater.TokenInitialized and currentRoute and not spoofing and not phantom
                languageSet = retVal
                Helpers.Log.Info 'Setting new session language, from: ' + sessionLang + ' to ' + retVal + ' (forced: ' + forcing + ')'
                Helpers.Client.MeteorHelper.CallMethod {
                    background: true
                    method: 'setSessionLanguage'
                    params: [
                        retVal
                        forcing
                    ]
                    callback: (error, result) ->
                        if result
                            Helpers.Client.SessionHelper.ParseClientData result
                }

            # storing in user
            if Meteor.userId()

                user = new MeteorUser Meteor.user()

                if not user.anonymous and user.lang isnt retVal and lastUserLanguageSet isnt retVal and currentRoute and not spoofing and not phantom
                    Helpers.Client.MeteorHelper.CallMethod {
                        method: 'setUserLanguage'
                        params: [
                            retVal
                            forcing
                        ]
                        background: true
                    }
                    lastUserLanguageSet = retVal

            return retVal

        else if Meteor.isServer

            lang = null

            if path
                lang = @GetLanguageByPath path

            # Priority to user lang
            if not lang
                if Helpers.Server.Auth.GetCurrentConnectionId() and Meteor.userId()
                    user = new MeteorUser(Meteor.user)
                    lang = user.lang

            # Then session
            if not lang
                sessionLang = Helpers.Server.Session.Get @LANGUAGE_KEY
                lang =  sessionLang || ServerSettings.defaultLanguage

            # Then default
            if lang not in (ServerSettings.languages || [])
                lang = ServerSettings.defaultLanguage

            # Also re-storing it in the session for the next time
            if Meteor.isServer and lang isnt sessionLang
                Helpers.Server.Session.Set @LANGUAGE_KEY, lang, true, true

            return lang.toString()

    @GetLanguageByRoute: (routeName) =>
        routeName = routeName || Router.current().route.getName()

        routeLang = routeName.substr 0, 3
        if routeLang[2] is '_'
            routeLang = routeLang.substr 0, 2
            if routeLang in ServerSettings.languages
                return routeLang
        return ServerSettings.defaultLanguage

    # Clean route name from language prefix
    @CleanRouteName: (routeName) =>
        if not routeName
            return routeName
        routeLang = routeName.substr 0, 3
        if routeLang[2] is '_'
            routeLang = routeLang.substr 0, 2
            if routeLang in ServerSettings.languages
                return routeName.substr(3)
        return routeName

    if Meteor.isServer
        Crater.startup ->
            translationService = Crater.Services.Get Services.TRANSLATOR

# Redefining Router.Path from iron router to ensure we take care of using the right localised route
_routerPath = Helpers.Router.Path
Helpers.Router.Path = (route, params, options) =>

    if typeof route is 'string'
        route = Router.routes[route]

    if not route?.path
        return null

    # Ensuring we deal with the main route, not the localised one
    routeName = route.getName()
    cleanRouteName = Helpers.Translation.CleanRouteName routeName

    if cleanRouteName isnt routeName
        route = Router.routes[cleanRouteName]

    lang = (options?.lang || Helpers.Translation.GetUserLanguage()).toString()

    path = null

    if lang is ServerSettings.defaultLanguage
        path = _routerPath route, params, options
    else
        route = Router.routes[lang + '_' + route.getName()]
        path = _routerPath route, params, options

    if options?.absolute
        if path?.length and path[0] is '/'
            path = path.substr 1

        return Meteor.absoluteUrl(path)
    else
        return path

# Ensuring Router.go returns the right localised route
_routerGo = Router.go
Router.go = (routeName, params...) ->

    Helpers.Log.Info 'Going to new route: ' + routeName + ' - params: ' + JSON.stringify(params || {})

    if Router.routes[routeName]
        lang = Helpers.Translation.GetUserLanguage()

        if lang is ServerSettings.defaultLanguage
            return _routerGo.apply @, [routeName].concat(params || [])
        else
            return _routerGo.apply @, [lang + '_' + routeName].concat(params || [])
    else
        return _routerGo.apply @, [routeName].concat(params || [])

if Meteor.isClient
    UI.registerHelper 'pathFor', (routeName, params) ->
        Helpers.Router.Path Router.routes[routeName], params

if Meteor.isServer
    Meteor.startup ->
        _sendWithMandrill = Helpers.Server.Email.sendWithMandrill

        Helpers.Server.Email.sendWithMandrill = (slug, params...) ->

            slug = slug + '-' + Helpers.Translation.GetUserLanguage()

            _sendWithMandrill.apply @, [slug].concat(params || [])

globalContext.translate = @Helpers.Translation.Translate