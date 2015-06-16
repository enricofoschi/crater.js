class @Crater.Api.BasicAuth extends @Crater.Api.Base

    '''
    {
        username: 'test'
        password: 'test'
    }
    '''
    _authenticationType: 'basic'

    _setAuthentication: (method, url, options) =>

        options.auth = @_authentication.username + ':' + @_authentication.password