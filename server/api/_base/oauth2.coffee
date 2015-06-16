class @Crater.Api.OAuth2 extends @Crater.Api.Base

    _authenticationType: 'oauth2'

    _setAuthentication: (method, url, options) =>

        token = @_getToken(options)
        if not token
            console.log 'No access token found'
            throw 'No access token found'

        options.headers = _.extend options.headers || {}, {
            Authorization: 'Bearer ' + token
        }