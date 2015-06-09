@Crater.Api.Google = {}

class @Crater.Api.Google.Base extends @Crater.Api.Base

    @_authenticationType = 'token'
    @_baseUrl = 'https://www.googleapis.com/'

    @_getToken = (options) =>

        options.custom.user.getGoogleAccessToken()

    @Call: (method, url, options, callback) =>

        user = null

        if options?.custom?.user
            if typeof(options.custom.user) is 'string'
                user = new MeteorUser(options.custom.user)
            else
                user = new MeteorUser(options.custom.user)
        else
            user = new MeteorUser(Meteor.user())

        options ||= {}
        options.custom ||= {}
        options.custom.user = user

        super method, url, options, (error, result) =>
            if error && error.response && error.response.statusCode is 401
                console.log '401 - attempting token refresh'
                refreshToken(user, =>
                    @Call method, url, options, callback
                )
            else
                callback error, result

    refreshToken = (user, callback) =>
        userRefreshToken = user.getRefreshToken()

        if not userRefreshToken
            throw 'No refresh token available'

        result = Meteor.http.call 'POST', 'https://accounts.google.com/o/oauth2/token', {
            params:
                client_id: Meteor.settings.google.clientId
                client_secret: Meteor.settings.google.secret
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
