class @Helpers.Log

    logService = null

    if Meteor.isServer
        logService = Crater.Services.Get Services.LOG

    @Info: (msg) =>

        if Meteor.isClient
            if console?.info
                console.info msg
        else
            logService.Info msg


    @Error: (msg) =>
        if Meteor.isClient
            if console?.error
                console.error msg
        else
            logService.Error msg