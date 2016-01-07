Meteor.methods {
    'addEmptyTranslation': (key, route, routeParams) ->

        check key, String

        if route
            check route, String
            check routeParams, Match.Any

        translatorService = Crater.Services.Get Services.TRANSLATOR
        translatorService.addEmptyTranslation key, route, routeParams

    'removeTranslation': (key) ->

        check key, String

        translatorService = Crater.Services.Get Services.TRANSLATOR
        translatorService.removeTranslation key

    'setSessionLanguage': (lang, forcing) ->

        check lang, String

        if forcing
            check forcing, Boolean

        wasForced = Helpers.Server.Session.Get Helpers.Translation.LANGUAGE_FORCED_KEY

        if wasForced and not forcing
            return sessionData?.clientData || {}

        if not forcing and not wasForced
            forcing = true

        sessionData = Helpers.Server.Session.Set Helpers.Translation.LANGUAGE_KEY, lang, true, true

        if forcing
            Helpers.Server.Session.Set Helpers.Translation.LANGUAGE_FORCED_KEY, true, true, true

        return sessionData?.clientData || {}

    'translations.clearDuplicates': ->
        if not Roles.userIsInRole Meteor.userId(), 'admin'
            throw 'Damn'

        translations = Translation.all()

        for translation in translations
            Translation.destroyAll {
                key: translation.key
                lang: translation.lang
                _id:
                    $ne: translation._id
                $or: [
                    {
                        value: null
                    }
                    {
                        value: ''
                    }
                    {
                        value:
                            $exists: false
                    }
                ]
            }

    'translations.clearForRoute': (route)->

        if not Roles.userIsInRole Meteor.userId(), 'admin'
            throw 'Whatever'

        Translation.destroyAll {
            route: route
        }
}

@AVOID_THROTTLING_FOR.push 'addEmptyTranslation'