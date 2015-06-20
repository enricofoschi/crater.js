global = @

class @Crater.Services.Core.Translation extends @Crater.Services.Core.Base

    addEmptyTranslation: (key, route) ->
        for lang in GlobalSettings.languages

            obj = {
                key: key
                route: route
                lang: lang
            }

            if key.indexOf('commons.') is 0
                obj.common = true

            global.Translation.create obj


    translate: (doc) ->
        DDP._CurrentInvocation.get()
        console.log doc