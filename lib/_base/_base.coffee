@Crater = {}

# Callbacks executed once all _beforeStartup promises succeed
Crater._startupCallbacks = []

# Promises that need to be resolved before triggering Crater.Startup
Crater._beforeStartup = []

Crater.beforeStartup = (promise, priority = 100) ->
    Crater._beforeStartup.push {
        promise: promise
        priority: priority
    }

Crater.startup = (func, priority = 100) ->
    Crater._startupCallbacks.push {
        func: func
        priority: priority
    }

if Meteor.isClient
    Crater._startedDeferred = $.Deferred()

Crater.onStartup = =>
    for callback in _.sortBy(Crater._startupCallbacks, (c) -> c.priority)
        callback.func()

    if Meteor.isClient
        Crater._startedDeferred.resolve()

Meteor.startup ->
    if Meteor.isClient

        promisesByPriorityObj = _.groupBy(Crater._beforeStartup, (c) -> c.priority)
        promisesByPriorityList = []

        for own key, value of promisesByPriorityObj
            promisesByPriorityList.push _.map(value, (p) -> p.promise)

        currentIndex = 0

        runPromises = =>
            Helpers.Log.Info 'Running priorities: ' + currentIndex
            Helpers.Log.Info promisesByPriorityList[currentIndex]
            $.when.apply($, promisesByPriorityList[currentIndex]).done(=>
                currentIndex++;
                if promisesByPriorityList[currentIndex]
                    runPromises()
                else
                    Crater.onStartup()
            )

        runPromises()
    else
        Crater.onStartup()

