Meteor.publish 'common_translations', (lang) ->
    @unblock();
    Translation.find {
        common: true
        lang: lang
    }, {
        fields:
            key: 1
            lang: 1
            value: 1
            common: 1
    }

Meteor.publish 'translations', (lang, route) ->

    @unblock();

    if route
        Translation.find {
            lang: lang
            routes:
                $elemMatch:
                    name: route
        }, {
            fields:
                key: 1
                lang: 1
                value: 1
        }
    else
        Translation.find {
            _id: 0
        }