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
    @_authentication = null
    @_baseUrl = ''
    @_contentType = 'application/json'

    '''
    Possible extensions:
    @Callback: (e, r)

    '''

    @Call: (method, url, callback, options) ->

        options = _.extend(options || {}, {
            headers: {
                'content-type': @_contentType
            }
        })

        if @_authentication and @_authentication.username
            options.auth = @_authentication.username + ':' + @_authentication.password

        HTTP.call method, url, options, (e, r) =>
            if @Callback
                @Callback callback, e, r
            else
                a = callback e, r

    @All: (callback) ->
        @Call 'get', @_baseUrl, callback

    @Get: (id, callback) ->
        @Call 'get', @_baseUrl + '/' + id, callback