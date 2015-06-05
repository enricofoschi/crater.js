@Crater = {
    Api: {}
}

class @Crater.Api.Base

    '''
    Authentication obj:
    {
        username: 'test'
        password: 'test'
    }
    '''
    @_authenticationType = 'basic'
    @_authentication = null
    @_getToken = null
    @_callback = null

    @_baseUrl = ''
    @_contentType = 'application/json'


    @Call: (method, url, options, callback) ->

        options = _.extend(options || {}, {
            headers: {
                'content-type': @_contentType
            }
        })


        if @_authenticationType is 'basic' and @_authentication.username
            options.auth = @_authentication.username + ':' + @_authentication.password

        if @_authenticationType is 'token' and @_getToken
            token = @_getToken(options)

            if not token
                console.log 'No access token found'
                throw 'No access token found'

            options.headers = _.extend options.headers || {}, {
                Authorization: 'Bearer ' + token
            }

        delete(options.custom)

        HTTP.call method, @_baseUrl + url, options, (e, r) =>
            if @_callback
                @_callback e, r, callback
            else
                callback e, r

    @All: (callback) ->
        @Call 'get', '', callback

    @Get: (id, callback) ->
        @Call 'get', id, callback