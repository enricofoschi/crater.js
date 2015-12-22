class @Crater.Services.Core.Log extends @Crater.Services.Core.Base

    @prefix: ''


    SetPrefix: (prefix) =>
        @prefix = prefix

    getArguments: (args) =>
        if @prefix then [@prefix].pushArray(args) else args

    Log: =>
        if console?.log
            console.log.apply console, @getArguments(arguments)

    Info: =>
        if console?.info
            console.info.apply console, @getArguments(arguments)

    Error: =>
        if console?.error
            console.error.apply console, @getArguments(arguments)
