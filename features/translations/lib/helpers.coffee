globalContext = @

class @Helpers.Translation

    translator = null
    translations = null
    LANGUAGE_KEY = 'session_lang'
    routeLoaded = null
    commonTranslationsLoaded = false

    commonTranslations = {}

    @Reset: =>
        commonTranslations = {}

        @Init()

    loadTranslations = (filters) =>
        translationData = globalContext.Translation.where filters

        translations = _.extend {}, commonTranslations || {}

        for translation in translationData
            translations[translation.key] = translation.value || ''

    @Init: =>
        if globalContext.Translation

            if Meteor.isClient
                if not commonTranslationsLoaded
                    translations = null

                    loadTranslations {
                        common: true
                    }
                    commonTranslationsLoaded = true

                    # Caching Global Translations
                    commonTranslations = _.extend {}, translations

                    Helpers.Log.Info 'Global Translations Loaded'

                route = Helpers.Router.GetCurrentRouteName()

                if route is not routeLoaded and route
                    loadTranslations {
                        route: route
                    }
                    Helpers.Log.Info 'Route Translations Loaded for ' + route
                    routeLoaded = route

            else if Meteor.isServer
                if not translations
                    loadTranslations {}
                    Helpers.Log.Info 'All translations loaded'

    @Translate: (key) =>
        @Init()

        if not translations[key] and translations[key] isnt ''
            if Meteor.isClient

                Helpers.Log.Info 'Missing key ' + key

                Helpers.Client.MeteorHelper.CallMethod {
                    method: 'addEmptyTranslation'
                    params: [
                        key
                        Router.current?()?.route?.getName()
                    ]
                }
            else
                translatorService = Crater.Services.Get Services.TRANSLATOR
                translatorService.addEmptyTranslation key, Router.current?()?.route?.getName()

        translations[key] || "%#{key}%"

    @GetUserLanguage: =>

        if Meteor.isClient
            if location.pathname.length > 1
                langPath = location.pathname.substring(0, if location.pathname.length is 2 then 2 else 3)

                if langPath[langPath.length - 1] is '/'
                    langPath = langPath.substring(0, langPath.length - 1)

                if langPath in GlobalSettings.languages
                    return langPath

                return GlobalSettings.defaultLanguage

        else if Meteor.isServer
            sessionLang = Helpers.Server.Session.Get(LANGUAGE_KEY)
            lang =  sessionLang || GlobalSettings.defaultLanguage

            if lang not in (GlobalSettings.languages || [])
                lang = GlobalSettings.defaultLanguage

            if Meteor.isServer and lang isnt sessionLang
                Helpers.Server.Session.Set LANGUAGE_KEY, lang, true, true

            return lang

    if Meteor.isServer
        Crater.startup ->
            translationService = Crater.Services.Get Services.TRANSLATOR
    else if Meteor.isClient
        Crater.beforeStartup(Helpers.Promises.FromSubscription('common_translations', @GetUserLanguage()), 10)

Helpers.Router.Path = (route, params, options) =>

    if not route?.path and route?.path isnt ''
        return null

    path = route.path params, options

    lang = ((options || {}).lang || Helpers.Translation.GetUserLanguage()).toString()

    if lang is GlobalSettings.defaultLanguage
        return path
    else
        return '/' + lang + path

if Meteor.isClient
    UI.registerHelper 'pathFor', (route, params) ->
        Helpers.Router.Path route, params


globalContext.translate = @Helpers.Translation.Translate