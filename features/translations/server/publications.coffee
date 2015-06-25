Meteor.publish 'common_translations', (lang) ->
    Translation.find {
        common: true
        lang: lang
    }

Meteor.publish 'translations', (lang, route) ->
    Translation.find {
        route: route
        lang: lang
    }