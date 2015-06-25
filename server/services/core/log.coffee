class @Crater.Services.Core.Log extends @Crater.Services.Core.Base

    Info: (msg) ->
        if console?.info
            console.info msg

    Error: (msg) ->
        if console?.error
            console.error msg