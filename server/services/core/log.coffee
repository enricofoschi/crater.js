class @Crater.Services.Core.Log extends @Crater.Services.Core.Base

    Log: ->
        if console?.log
            console.log.apply console, arguments

    Info: ->
        if console?.info
            console.info.apply console, arguments

    Error: ->
        if console?.error
            console.error.apply console, arguments