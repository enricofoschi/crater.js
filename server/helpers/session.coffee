Global = @

class @Helpers.Server.Session

    connections = []
    spoofingConnections = {}

    @RemoveToken: ->

        connectionId = Helpers.Server.Auth.GetCurrentConnectionId.apply @

        if connections[connectionId]
            Object.deleteProperty connections, connectionId

    @SetToken: (token) ->
        connectionId = Helpers.Server.Auth.GetCurrentConnectionId.apply @

        if connectionId
            connections[connectionId] = token

    @GetSessionToken: ->
        connectionId = Helpers.Server.Auth.GetCurrentConnectionId.apply @
        connections[connectionId]

    @Set: (key, value, forClient=false, forServer=true) ->

        sessionToken = Session.GetSessionToken.apply @

        if sessionToken
            sessionData = null

            sessionData = CurrentUserSession.first {
                token: sessionToken
            }

            if not sessionData
                sessionData = CurrentUserSession.create {
                    token: sessionToken
                    clientData: {
                        init: true
                        missing: true
                    }
                }

            sessionData.setData key, value, forClient, forServer

            return sessionData

        return null

    @Get: (key, fromClient=false) ->

        connectionId = Helpers.Server.Auth.GetCurrentConnectionId.apply @
        if connections[connectionId]
            sessionData = CurrentUserSession.first {
                token: connections[connectionId]
            }

            if not sessionData
                return

            values = sessionData.getData key

            if fromClient
                return values.client
            else
                return values.server

    @SetSpoofing: (val) ->

        connectionId = Helpers.Server.Auth.GetCurrentConnectionId.apply @
        if connectionId
            spoofingConnections[connectionId] = true

    @GetSpoofing: (val) ->
        connectionId = Helpers.Server.Auth.GetCurrentConnectionId.apply @
        spoofingConnections[connectionId]



    Meteor.server.onConnection (connection) ->
        connection.onClose ->
            Helpers.Server.Session.RemoveToken
            if spoofingConnections[connection.id]
                delete spoofingConnections[connection.id]