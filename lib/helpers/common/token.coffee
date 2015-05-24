class @Helpers.Token

    @GetRandom: ->
        Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1)

    @GetGuid: ->
        @GetRandom() + @GetRandom() + '-' + @GetRandom() + '-' + @GetRandom() + '-' + @GetRandom() + '-' + @GetRandom() + @GetRandom() + @GetRandom()