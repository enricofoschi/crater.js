globalContext = @

class @Helpers.Translation

    translator = null
    translations = null
    LANGUAGE_KEY = 'session_lang'

    @Reset: =>
        translations = null
        @Init()

    @Init: =>
        if (translations is null or not Object.keys(translations).length) and globalContext.Translation
            console.log 'Rewriting translations'
            translations = {}
            translationData = globalContext.Translation.where {
                lang: @GetUserLanguage()
            }
            for translation in translationData
                translations[translation.key] = translation.value || ''

    @Translate: (key) =>

        @Init()

        if not translations[key] and translations[key] isnt ''
            if Meteor.isClient

                console.log 'Missing key ' + key

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
        Crater.beforeStartup Helpers.Promises.FromSubscription 'translations'


globalContext.translate = @Helpers.Translation.Translate