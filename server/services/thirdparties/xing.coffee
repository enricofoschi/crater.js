class @Crater.Services.ThirdParties.Xing extends @Crater.Services.ThirdParties.Base

    _authenticationApi = null
    _token = null

    constructor: (key, secret) ->

        authentication = {
            key: key
            secret: secret
        }

        @_authenticationApi = new Crater.Api.Xing.Authentication authentication

    getToken: (connection, callback) ->
        Meteor.wrapAsync(@_authenticationApi.getAuthenticationUrl) connection, callback



