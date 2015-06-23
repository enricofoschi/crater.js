@Crater = {}

# Callbacks executed once all _beforeStartup promises succeed
Crater._startupCallbacks = []

# Promises that need to be resolved before triggering Crater.Startup
Crater._beforeStartup = []

Crater.beforeStartup = (promise) ->
    Crater._beforeStartup.push promise

Crater.startup = (func, priority = 0) ->
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
        $.when.apply($, Crater._beforeStartup).done Crater.onStartup
    else
        Crater.onStartup()

