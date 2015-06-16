Global = @

class @Helpers.Server.Session

    connections = []

    @RemoveToken: (connection) ->

        if connections[connection.id]
            delete connections[connection.id]

    @SetToken: (connection, token) ->
        connections[connection.id] = token

    @Set: (connection, key, value, forClient=false, forServer=true) ->

        if connections[connection.id]
            sessionData = null

            sessionData = CurrentUserSession.firstOrCreate {
                token: connections[connection.id]
            }

            sessionData.setData key, value, forClient, forServer

            sessionData

    @Get: (connection, key, fromClient=false) ->
        if connections[connection.id]

            sessionData = CurrentUserSession.first {
                token: connections[connection.id]
            }

            values = sessionData.getData key

            if fromClient
                return values.client
            else
                return values.server



    Meteor.server.onConnection (connection) ->
        connection.onClose ->
            Helpers.Server.Session.RemoveToken connection