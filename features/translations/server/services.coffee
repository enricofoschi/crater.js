global = @

class @Crater.Services.Core.Translation extends @Crater.Services.Core.Base

    addEmptyTranslation: (key, route, routeParams) =>

        route = Helpers.Translation.CleanRouteName route

        for lang in ServerSettings.languages

            @addTranslation lang, key, null, route, routeParams

    addTranslation: (lang, key, value, route, routeParams) ->

        obj = {
            key: key
            lang: lang
            value: value
            routes: []
        }

        if key.indexOf('commons.') is 0
            obj.common = true
        else
            if route
                obj.routes.push {
                    name: route
                    params: routeParams
                }

        if global.Translation.count() or Helpers.Server.Auth.GetCurrentConnection()
            existingTranslation = global.Translation.first {
                key: key
                lang: lang
            }

            # Adding the translation if it doesn't exists
            if not existingTranslation
                global.Translation.create obj
            # linking existing route otherwise
            else if not existingTranslation.common and not _.find(existingTranslation.routes || [], (r) -> r.name is route) and route
                existingTranslation.push {
                    routes: [
                        {
                            name: route
                            params: routeParams
                        }
                    ]
                }

    translate: (doc) ->
        DDP._CurrentInvocation.get()

    removeTranslation: (key) ->
        global.Translation.destroyAll {
            key: key
        }

@Services.TRANSLATOR =
    key: 'translator'
    service: -> new Crater.Services.Core.Translation()

@Crater.Services.Set(@Services.TRANSLATOR)
