Meteor.publish 'translations', (route) ->
    lang = 'en'

    Translation.find {
        $and: [
            {
                $or: [
                    {
                        common: true
                    },
                    {
                        route: route
                    }
                ]
            },
            {
                language: lang
            }
        ]
    }