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

            route = Router.current?()?.route?.getName()

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

                if route is not routeLoaded
                    loadTranslations {
                        route: route
                    }
                    Helpers.Log.Info 'Route Translations Loaded for ' + route

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

        sessionHandler = if Meteor.isServer then Helpers.Server.Session else Helpers.Client.SessionHelper

        lang = sessionHandler?.Get(LANGUAGE_KEY) || GlobalSettings?.defaultLanguage

        if lang not in (GlobalSettings?.languages || [])
            lang = GlobalSettings?.defaultLanguage

        sessionHandler?.Set LANGUAGE_KEY, lang, true, true

        lang || 'en'

    if Meteor.isServer
        Crater.startup ->
            translationService = Crater.Services.Get Services.TRANSLATOR
    else if Meteor.isClient
        Crater.beforeStartup(Helpers.Promises.FromSubscription('common_translations', @GetUserLanguage()), 10)

Helpers.Router.Path = (route, params, options) =>

    if not route?.path
        return null

    path = route.path params, options

    lang = Helpers.Translation.GetUserLanguage()

    if lang is GlobalSettings?.defaultLanguage
        return path
    else
        return '/' + lang + path

if Meteor.isClient
    UI.registerHelper 'pathFor', (route, params) ->
        Helpers.Router.Path route, params


globalContext.translate = @Helpers.Translation.Translate