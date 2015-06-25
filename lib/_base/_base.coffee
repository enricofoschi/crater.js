@GlobalSettings = {
    adminRoles: ['admin']
    companyName: '4Scotty'
    languages: ["en", "de"]
    defaultLanguage: "en"

}

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

    if Meteor.isClient
        Helpers.Log.Info 'Client Startup'

        promises = []
        for callback in Crater._startupCallbacks
            promises.push {
                promise: Helpers.Promises.FromSyncFunction(callback.func)
                priority: callback.priority
            }

        Helpers.Promises.RunInSequence(Crater._beforeStartup).done(=>
            Helpers.Log.Info 'Client Initialised'
            Crater._startedDeferred.resolve()
        )
    else
        for callback in _.sortBy(Crater._startupCallbacks, (c) -> c.priority)
            callback.func()

Meteor.startup ->
    if Meteor.isClient
        Helpers.Log.Info 'Client Before Startup'
        Helpers.Promises.RunInSequence(Crater._beforeStartup).done(Crater.onStartup)
    else
        Crater.onStartup()

