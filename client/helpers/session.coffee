class @Helpers.Client.SessionHelper

    TOKEN_KEY = 'token'
    CLIENT_DATA = 'client'

    ''' Ensures the token is refreshed or created if not available'''
    @EnsureToken: =>
        token = Helpers.Client.Storage.Get TOKEN_KEY
        clientData = null

        if not token
            Meteor.call 'getNewSessionToken', (errors, results) =>
                if not errors
                    Helpers.Client.Storage.Set TOKEN_KEY, results.token
                    @ParseClientData results.clientData if results?.clientData
        else
            Meteor.call 'persistSessionToken', token, (errors, results) =>
                @ParseClientData results.clientData if results?.clientData

    ''' Ensures that the data that should be available on the client is actually loaded
        into che client Session '''
    @ParseClientData: (clientData) ->
        Helpers.Client.Storage.Set CLIENT_DATA, clientData

        Session.set CLIENT_DATA, clientData

    @Refresh: ->
        @EnsureToken()

    @Get: (key) ->

        clientData = Session.get CLIENT_DATA

        if clientData?[key] then clientData[key] else Session.get(key)

    ''' Sets a new value on the client available data, stored on the server and reloaded'''
    @Set: (key, value) ->
        Meteor.call 'setSessionValue', key, value, (errors, results) ->
            @ParseClientData results.clientData if results and results.clientData