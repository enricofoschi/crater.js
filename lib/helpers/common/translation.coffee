globalContext = @

class @Helpers.Translation

    translator = null
    translations = null
    LANGUAGE_KEY = 'session_lang'

    @Init: ->
        if translations is null and globalContext.Translation
            translations = []
            translationData = globalContext.Translation.all()
            for translation in translationData
                translations[translation.key] = translation

    @Translate: (key) =>

        @Init()


        if not translations[key]
            if Meteor.isClient
                Helpers.Client.MeteorHelper.CallMethod {
                    method: 'addEmptyTranslation'
                    params: [
                        key
                        Router.current()?.route?.getName()
                    ]
                }
            else
                translatorService.addEmptyTranslation key, Router.current()?.route?.getName()

        translations[key]?.value || "%#{key}%"

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