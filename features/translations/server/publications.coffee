Meteor.publish 'translations', (route=null) ->
    lang = 'en'

    Translation.find {
        $or: [
            {
                common: true
            },
            {
                route: route
            }
        ],
        lang: lang
    }