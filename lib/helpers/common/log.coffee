class @Helpers.Log

    logService = null
    debugMode = false
    start = new Date()
    ticks = [start]
    previousTick = null

    # Hosts
    @ClientDebugHosts: [
        'localhost'
    ]

    @AddClientHost: (host) =>
        @ClientDebugHosts.push host

    # Client Specific
    debugContainer = null
    debugList = null

    if Meteor.isServer
        logService = Crater.Services.Get Services.LOG

    @InitDebug: =>
        if not debugContainer
            debugContainer = $ '<div class="debug-container"></div>'
            debugList = $ '<ul class="logs-list list-unstyled"></ul>'
            debugContainer.append debugList
            $(document.body).append debugContainer

    @EnableDebug: =>
        @InitDebug()
        debugMode = true

    @DisableDebug: =>
        debugMode = false

    @DebugModeLog: (type, logs) =>
        if Meteor.isClient and debugMode

            for log in logs
                newLog = $ '<li></li>'
                newLog.text '[' + type + '] ' + log
                debugList.append newLog

    @LogOnClient: (type, parameters) =>
        if console and location.hostname in @ClientDebugHosts and console[type]
            console[type].apply console, parameters

        if type is 'error'
            try
                Helpers.Client.MeteorHelper.CallMethod {
                    method: 'logError'
                    params: parameters
                    background: true
                }
            catch e

    @Tick: (msg) =>
        if ServerSettings.debug

            ticks.push new Date()

            timeSpent = (ticks[ticks.length - 1] - ticks[ticks.length - 2]) / 1000
            if timeSpent > 0.5
                @Info(
                    'Tick:'
                    msg
                    'Since last'
                    (ticks[ticks.length - 1] - ticks[ticks.length - 2]) / 1000
                    'Since start'
                    (ticks[ticks.length - 1] - ticks[0]) / 1000
                    'Previous tick'
                    previousTick
                )
            previousTick = msg

    @Log: =>
        if Meteor.isClient
            @LogOnClient 'log', arguments
        else
            logService.Log.apply @, arguments

        @DebugModeLog 'log', arguments

    @Info: =>
        if Meteor.isClient
            @LogOnClient 'info', arguments
        else
            logService.Info.call @, arguments

        @DebugModeLog 'info', arguments


    @Error: =>
        if Meteor.isClient
            @LogOnClient 'error', arguments
        else
            logService.Error.apply @, arguments

        @DebugModeLog 'error', arguments