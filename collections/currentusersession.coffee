class @CurrentUserSession extends BaseCollection
    # indicate which collection to use
    @_collection: new Mongo.Collection('user_session_data')

    @before_create: (attr) ->
        attr ||= attr
        attr.updatedAt = new Date
        attr.token ||= (Helpers.Token.GetGuid() + Helpers.Token.GetGuid())
        attr.serverData ||= {}
        attr.clientData ||= {}
        attr

    @before_save: (attr) ->
        attr ||= attr
        attr.updatedAt = new Date
        attr

    @schema: {
        token:
            type: String
            max: 72
        serverData:
            blackbox: true,
            type: Object
            label: 'Server Data'
        clientData:
            blackbox: true
            type: Object
            label: 'Client Data'
    }

    getData: (key) ->
        {
            client: @clientData[key]
            server: @serverData[key]
        }

    setData: (key, value, forClient, forServer) ->
        dataKeys = []

        dataKeys.push 'clientData' if forClient
        dataKeys.push 'serverData' if forServer

        updateObj = {}

        for dataKey in dataKeys
            data = @[dataKey] || {}
            data ||= data
            data[key] = value
            updateObj[dataKey] = data

        @update updateObj

    forClient: ->
        {
            token: @token
            clientData: @clientData
        }

Meteor.startup( ->

    if Meteor.isServer
        CurrentUserSession._collection._ensureIndex {
            createdAt: 1
        }, {
            expireAfterSeconds: Meteor.settings.sessionLength
        }
        CurrentUserSession._collection._ensureIndex {
            token: 1
        }
)