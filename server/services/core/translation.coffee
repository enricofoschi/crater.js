class @Crater.Services.Core.Translation extends @Crater.Services.Core.Base

    getLanguage: ->


    translate: (doc) ->
        DDP._CurrentInvocation.get()
        console.log doc