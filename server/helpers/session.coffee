Global = @

class @Helpers.Server.Session

    connections = []

    @RemoveToken: ->

        connectionId = Helpers.Server.Auth.GetCurrentConnectionId.apply @

        if connections[connectionId]
            delete connections[connectionId]

    @SetToken: (token) ->
        connectionId = Helpers.Server.Auth.GetCurrentConnectionId.apply @

        connections[connectionId] = token

    @Set: (key, value, forClient=false, forServer=true) ->

        connectionId = Helpers.Server.Auth.GetCurrentConnectionId.apply @

        if connections[connectionId]
            sessionData = null

            sessionData = CurrentUserSession.firstOrCreate {
                token: connections[connectionId]
            }

            sessionData.setData key, value, forClient, forServer

            sessionData

    @Get: (key, fromClient=false) ->

        connectionId = Helpers.Server.Auth.GetCurrentConnectionId.apply @

        if connections[connectionId]

            sessionData = CurrentUserSession.first {
                token: connections[connectionId]
            }

            values = sessionData.getData key

            if fromClient
                return values.client
            else
                return values.server



    Meteor.server.onConnection (connection) ->
        connection.onClose ->
            Helpers.Server.Session.RemoveToken