Meteor.methods {
    'persistSessionToken': (token) ->
        sessionData = CurrentUserSession.first {
            token: token
        }
        if sessionData
            sessionData.save()
        else
            sessionData = CurrentUserSession.create {
                token: token
            }

        if sessionData.errors
            false
        else
            Helpers.Server.Session.SetToken token
            sessionData.forClient()

    'getNewSessionToken': ->
        sessionData = CurrentUserSession.create()
        token = sessionData
        Helpers.Server.Session.SetToken token
        sessionData.forClient()

    'setSessionValue': (key, value) ->
        data = Helpers.Server.Session.Set key, value, true
        data.forClient()
}