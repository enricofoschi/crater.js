class @Helpers.Client.Storage

    @Set: (key, value, options = null) ->
        amplify.store key, value, options

    @SetNative: (key, value, options = null) ->
        localStorage.setItem key, value, options

    @GetNative: (key, value) ->
        localStorage.getItem key

    @Get: (key) ->
        amplify.store key

    @Clear: (key) ->
        amplify.store key, null

    @GetCache: (key) =>
        stored = @Get key

        now = (new Date()).getTime()
        if stored and stored.expires - now >= 0 and Helpers.Router.GetQueryString().debug isnt '1'
            return JSON.parse(stored.value)
        else
            return null

    @SetCache: (key, value, seconds) =>
        @Set(key, {
            value: JSON.stringify(value)
        },{
            expires: 1000 * seconds
        })

