globalContext = @

class @Helpers.Translation

    translator = null
    translations = []
    LANGUAGE_KEY = 'session_lang'

    @Init: ->
        if not translations.length and globalContext.Translation
            translationData = globalContext.Translation.all()
            for translation in translationData
                translations[translation.key] = translation

    @Translate: (key) =>

        @Init()

        if Meteor.isClient
            if not translations[key]
                console.log key
                try
                    globalContext.Translation.create {
                        key: key
                        route: Router.current()?.route?.getName()
                        common: key.indexOf 'commons.' is 0
                        language: @GetUserLanguage()
                        value: null
                    }
                catch e
                    console.log e

        translations[key] || '%key%'

    if Meteor.isServer
        Meteor.startup ->
            translationService = Crater.Services.Get Services.TRANSLATOR

    @GetUserLanguage: =>

        sessionHandler = if Meteor.isServer then Helpers.Server.Session else Helpers.Client.SessionHelper

        lang = sessionHandler?.Get(LANGUAGE_KEY) || GlobalSettings?.defaultLanguage

        if lang not in (GlobalSettings?.languages || [])
            lang = GlobalSettings?.defaultLanguage

        sessionHandler?.Set LANGUAGE_KEY, lang, true, true

        lang || 'en'