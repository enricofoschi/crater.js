Meteor.methods {
    'getClientSettings': ->
        obj = {}
        if Meteor.settings.forClient
            for forClient in Meteor.settings.forClient
                obj[forClient] = Meteor.settings[forClient]
        obj
}