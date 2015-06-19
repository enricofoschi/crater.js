@Crater.Api.Google = {}

class @Crater.Api.Google.Base extends @Crater.Api.OAuth2

    _authenticationType: 'token'
    _baseUrl: 'https://www.googleapis.com/'

    _getToken: (options) =>
        options.custom.user.getGoogleAccessToken()

    Call: (method, url, options, callback) =>

        originalOptions = _.extend {}, options

        super method, url, options, (error, result) =>
            if error && error.response && error.response.statusCode is 401
                console.log '401 - attempting token refresh'
                @refreshToken(originalOptions.custom.user, =>
                    @Call method, url, originalOptions, callback
                )
            else
                if callback
                    callback error, result

    refreshToken: (user, callback) =>

        userRefreshToken = user.getGoogleRefreshToken()

        if not userRefreshToken
            throw 'No refresh token available'

        result = Meteor.http.call 'POST', 'https://accounts.google.com/o/oauth2/token', {
            params:
                client_id: @_authentication.clientId
                client_secret: @_authentication.secret
                refresh_token: userRefreshToken
                grant_type: 'refresh_token'
        }

        if result.statusCode is 200
            user.update {
                '$set':
                    'services.google.accessToken': result.data.access_token
                    'services.google.expiresAt': (+new Date) + (1000 * result.data.expires_in)
            }
            console.log 'Access token updated'
            callback()
