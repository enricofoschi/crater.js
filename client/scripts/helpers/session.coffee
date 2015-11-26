class @Helpers.Client.SessionHelper

    TOKEN_KEY = 'token'
    CLIENT_DATA = 'client'

    ''' Ensures the token is refreshed or created if not available'''
    @EnsureToken: (callback) =>
        if Session.get '___isRunningPhantomJS___'
            callback null, null
            return

        start = new Date()

        token = Helpers.Client.Storage.Get TOKEN_KEY

        # Log debugging data
        onTokenLoaded = (e, r) =>
            callback(e, r) if callback

        initClientData = {
            us: navigator?.userAgent
            loc: window.location?.href
            ref: document?.referrer
            init: true
        }

        if not token
            Helpers.Log.Info 'Getting New Session Token'
            Meteor.call 'getNewSessionToken', Helpers.Client.Auth.IsSpoofing(), initClientData, (errors, results) =>
                Helpers.Log.Info 'Done'
                if not errors
                    Helpers.Client.Storage.Set TOKEN_KEY, results.token
                    @ParseClientData results.clientData if results?.clientData
                onTokenLoaded errors, results
        else
            Helpers.Log.Info 'Persisting New Session Token (check spoofing)'
            isSpoofing = Helpers.Client.Auth.IsSpoofing()
            Helpers.Log.Info 'Starting check: ' + ((new Date()) - start) / 1000
            Meteor.call 'persistSessionToken', isSpoofing, token, initClientData, (errors, results) =>
                Helpers.Log.Info 'Done: ' + ((new Date()) - start) / 1000
                @ParseClientData results.clientData if results?.clientData
                onTokenLoaded errors, results


    ''' Ensures that the data that should be available on the client is actually loaded
        into che client Session '''
    @ParseClientData: (clientData) =>
        Helpers.Client.Storage.Set CLIENT_DATA, clientData
        Session.set CLIENT_DATA, clientData

    @Refresh: =>
        @EnsureToken()

    @Get: (key) =>
        clientData = Session.get CLIENT_DATA

        if clientData?[key] then clientData[key] else Session.get(key)

    ''' Sets a new value on the client available data, stored on the server and reloaded'''
    @Set: (key, value, callback) =>
        Meteor.call 'setSessionValue', key, value, (errors, results) =>
            @ParseClientData results.clientData if results and results.clientData
            if callback
                callback()