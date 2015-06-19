Meteor.publish 'translations', (route) ->
    lang = 'en'

    Translation.find {
        $or: [
            {
                common: true
            },
            {
                route: route
            },
            {
                language: lang
            }
        ]
    }