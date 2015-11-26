DEBUG_SESSIONS = false

Meteor.methods {
    'persistSessionToken': (isSpoofing, token, initClientData) ->

        logService = Crater.Services.Get Services.LOG
        start = new Date()
        MeteorUser.RecordLastSession() if not isSpoofing

        logService.Info('Recording last session: ' + ((new Date()) - start) / 1000) if DEBUG_SESSIONS

        sessionData = CurrentUserSession.first {
            token: token
        }
        if sessionData
            if ((new Date()) - sessionData.updatedAt) / 1000 / 60 / 60 / 24 > 1
                sessionData.save()
                logService.Info('Updating session: ' + ((new Date()) - start) / 1000) if DEBUG_SESSIONS
                start = new Date()
        else
            sessionData = CurrentUserSession.create {
                token: token
                clientData: initClientData
            }
            logService.Info('Creating session: ' + ((new Date()) - start) / 1000) if DEBUG_SESSIONS
            start = new Date()

        if sessionData.errors
            return false
        else
            Helpers.Server.Session.SetToken token
            logService.Info('Setting token: ' + ((new Date()) - start) / 1000) if DEBUG_SESSIONS
            start = new Date()
            return sessionData.forClient()

    'getNewSessionToken': (isSpoofing, clientData) ->

        MeteorUser.RecordLastSession() if not isSpoofing

        sessionData = CurrentUserSession.create {
            clientData: clientData
        }

        token = sessionData.token
        Helpers.Server.Session.SetToken token
        sessionData.forClient()

    'setSessionValue': (key, value) ->
        data = Helpers.Server.Session.Set key, value, true
        if not data
            Helpers.Log.Error 'No session data yet - cannot set', key, value
            return {
                clientData: null
                token: null
            }
        else
            return data.forClient()
}

@AVOID_THROTTLING_FOR.push 'persistSessionToken'
@AVOID_THROTTLING_FOR.push 'getNewSessionToken'
@AVOID_THROTTLING_FOR.push 'setSessionValue'