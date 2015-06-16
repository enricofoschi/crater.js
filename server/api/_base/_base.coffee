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

        # Extending specifying content type requested
        if @_contentType
            options = _.extend(options, {
                headers: {
                    'content-type': @_contentType
                }
            })

        @_setAuthentication(method, url, options)

        # Deleting possible custom options
        delete(options.custom)

        # Making the actual call

        HTTP.call method, url, options, (e, r) =>
            callback e, r

    All: (callback) ->
        @Call 'get', '', callback

    Get: (id, callback) ->
        @Call 'get', id, callback

        # Getting User if hidden in options
        user = null

    _getSessionKey: (key) =>
        @_serviceName + '_' + key
