class @Helpers.Client.Storage

    @Set: (key, value) ->
        amplify.store key, value

    @Get: (key) ->
        amplify.store key

    @Clear: (key) ->
        amplify.store key, null