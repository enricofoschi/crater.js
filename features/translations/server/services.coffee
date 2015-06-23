global = @

class @Crater.Services.Core.Translation extends @Crater.Services.Core.Base

    addEmptyTranslation: (key, route) =>
        for lang in GlobalSettings.languages

            @addTranslation lang, key, null, route

    addTranslation: (lang, key, value, route) ->
        obj = {
            key: key
            route: route
            lang: lang
            value: value
        }

        if key.indexOf('commons.') is 0
            obj.common = true

        existingTranslation = global.Translation.first {
            key: key
            lang: lang
        }

        if not existingTranslation
            global.Translation.create obj

    translate: (doc) ->
        DDP._CurrentInvocation.get()
        console.log doc

@Services.TRANSLATOR =
    key: 'translator'
    service: -> new Crater.Services.Core.Translation()

@Crater.Services.Set(@Services.TRANSLATOR)

