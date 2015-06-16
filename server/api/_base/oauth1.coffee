class @Crater.Api.OAuth1 extends @Crater.Api.Base

    oauthSigner = Npm.require('oauth-signature');

    '''
    Authentication obj:

    {
        key: 'test'
        secret: 'test'
    }
    '''
    _authenticationType: 'oauth1'
    _signatureMethod: 'HMAC-SHA1' # Used in case of oAuth 1

    _setAuthentication: (method, url, options) =>

        timestamp = Math.round((new Date()).getTime() / 1000)

        options.params = _.extend options.params || {}, {
            oauth_consumer_key: @_authentication.key
            oauth_signature_method: @_signatureMethod
            oauth_version: '1.0'
            oauth_timestamp: timestamp
            oauth_nonce: timestamp + '_' + Math.round(Math.random() * 1000)
        }

        token = @_getToken(options)
        token_secret = @_getTokenSecret(options)

        if not token or not token_secret
            throw 'No access token found'

        options.params.oauth_token = oauth_token
        options.params.oauth_secret = oauth_secret

        encryptedSignature = oauthSigner.generate method.toUpperCase(), @_baseUrl + url, options.params, @_authentication.secret, ''
        options.params.oauth_signature = decodeURIComponent(encryptedSignature)

    _setSignature: (options) ->
        options ||= {}

        signature = ''

        signatureParameters = []
        for own key, value of options.params || {}
            signatureParameters.push {
                key: encodeURIComponent key
                value: encodeURIComponent value
            }

        signatureParameters = _.sortBy signatureParameters, (e) -> e.key

        for signatureParameter in signatureParameters
            if signature.length
                signature += '&'
            signature += signatureParameter.key + '=' + signatureParameter.value

        options.params.oauth_signature = signature

    getAuthenticationUrl: (connection, callback) =>

        options = {
            params:
                oauth_callback: Meteor.absoluteUrl() + 'oauth/xing/callback'
        }

        @Call 'get', 'v1/request_token', options, (e, r) =>
            if e
                callback(e, null)
            else
                valuesStr = r.content.split '&'
                values = {}
                for valueStr in valuesStr
                    valueProperties = valueStr.split '='
                    values[valueProperties[0]] = valueProperties[1]

                Helpers.Server.Session.Set connection, @_getSessionKey(sessionKeyOAuthSecret), values.oauth_token_secret, false
                Helpers.Server.Session.Set connection, @_getSessionKey(sessionKeyOAuthToken), values.oauth_token, false

                callback null, @_baseUrl + 'v1/authorize?oauth_token=' + values.oauth_token

    exchangeToken: (connection, verifier, callback) =>

        options = {
            params:
                oauth_verifier: verifier
        }

        @Call 'get', 'v1/access_token', options, (e, r) ->
            console.log arguments
            callback e, r