@Crater.Api = {}

class @Crater.Api.Base

    '''
    Authentication obj:

    if _authenticationType is 'basic':
        {
            username: 'test'
            password: 'test'
        }
    '''
    _authenticationType: 'basic'
    _authentication: null
    _signatureMethod: ''
    _getToken: null
    _serviceName: null
    _setAuthentication: null

    _baseUrl: ''
    _contentType: ''
    _userAgent: null

    _logService: null

    constructor: (authentication) ->
        @_authentication = authentication

        @_logService = Crater.Services.Get Services.LOG


    Call: (method, url, options, callback) ->

        # Getting User if hidden in options
        user = null

        url = @_baseUrl + url

        if options?.custom?.user
            if typeof(options.custom.user) is 'string'
                user = new MeteorUser(options.custom.user)
            else
                user = new MeteorUser(options.custom.user)

        options ||= {}
        options.custom ||= {}
        options.custom.user = user
        options.headers ||= {}

        # Extending specifying content type requested
        if @_contentType
            options.headers['content-type'] = @_contentType

        if @_userAgent
            options.headers['user-agent'] = @_userAgent


        @_setAuthentication(method, url, options) if @_setAuthentication

        # Deleting possible custom options
        delete(options.custom)

        # Making the actual call

        HTTP.call method, url, options, (e, r) =>
            callback(e, r) if callback

    All: (callback) ->
        @Call 'get', '', callback

    Get: (id, callback) ->
        @Call 'get', id, callback

        # Getting User if hidden in options
        user = null

    Post: (data, callback) ->
        @Call 'post', '', {
            content: data
        }, callback

    _getSessionKey: (key) =>
        @_serviceName + '_' + key
