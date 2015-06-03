@Crater.Api.Google = {}

class @Crater.Api.Google.Base extends @Crater.Api.Base

    @_authenticationType = 'token'
    @_baseUrl = 'https://www.googleapis.com/'

    @_getToken = ->
        Meteor.user()?.services?.google?.accessToken

    @Call: (method, url, options, callback) =>

        super method, url, options, (error, result) =>
            if error && error.response && error.response.statusCode is 401
                console.log '401 - attempting token refresh'
                refreshToken =>
                    @Call method, url, options, callback
            else
                callback error, result

    refreshToken = (callback) =>
        refreshToken = Meteor.user()?.services?.google?.refreshToken

        if not refreshToken
            throw 'No refresh token available'

        result = Meteor.http.call 'POST', 'https://accounts.google.com/o/oauth2/token', {
            params:
                client_id: Meteor.settings.google.clientId
                client_secret: Meteor.settings.google.secret
                refresh_token: refreshToken
                grant_type: 'refresh_token'
        }

        if result.statusCode is 200
            Meteor.users.update Meteor.userId(), {
                '$set':
                    'services.google.accessToken': result.data.access_token
                    'services.google.expiresAt': (+new Date) + (1000 * result.data.expires_in)
            }
            console.log 'Access token updated'
            callback()
