# Implementing Throttling

@AVOID_THROTTLING_FOR = []

lastCallsByConnectionIds = {}
clearConnectionCounter = 0
clearConnectionEvery = 100 # how many method calls before we clear out the connections counter
throttleTime = 1000 # wait time in ms
maxQueue = 10

clearCallsByConnections = ->


wrapMethod = (key, func) ->

    return ->
        connectionId = Helpers.Server.Auth.GetCurrentConnectionId.apply @
        waitTime = 0
        recentCalls = null

        if connectionId
            recentCalls = lastCallsByConnectionIds[connectionId]

            if not recentCalls
                recentCalls = {}
                lastCallsByConnectionIds[connectionId] = recentCalls


            lastTime = recentCalls[key]?.time || 0

            now = (new Date()).getTime()

            if lastTime

                waitTime = (recentCalls[key].queue + 1) * throttleTime - (now - lastTime)
                if waitTime < 0
                    waitTime = 0

            if key in AVOID_THROTTLING_FOR
                waitTime = 0


            recentCalls[key] ||= {}

            recentCalls[key].queue = (recentCalls[key].queue || 0) + 1

            if recentCalls[key].queue > maxQueue
                throw 'Too many requests.'

        # Clearing connection data
        clearConnectionCounter++

        if clearConnectionCounter >= clearConnectionEvery
            clearCallsByConnections()

        if waitTime
            console.log 'Throttled ' + key
            Meteor.sleep waitTime
        if recentCalls[key]
            recentCalls[key].queue--
            recentCalls[key].time = (new Date()).getTime()

        func.apply @, arguments

Meteor.startup ->

    existingMethods = Meteor.server.method_handlers

    for own key, value of existingMethods
        existingMethods[key] = wrapMethod key, value

    _methods = Meteor.methods

    Meteor.methods = (newMethods) ->

        for own key, value of newMethods
            newMethods[key] = wrapMethod key, value

        _methods newMethods
