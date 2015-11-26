class @Helpers.Client.Storage

    @Set: (key, value) ->
        amplify.store key, value

    @SetNative: (key, value) ->
        localStorage.setItem key, value

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
        @Set key, {
            expires: (new Date()).addSeconds(seconds).getTime()
            value: JSON.stringify(value)
        }