globalContext = @

class @Helpers.Promises

    @FromSubscription: (subscription) =>
        deferred = $.Deferred()

        Meteor.subscribe subscription, {
            onReady: ->
                deferred.resolve()
            onError: ->
                deferred.reject()
        }

        return deferred.promise()

    @FromFunction: (func) =>
        deferred = $.DeferreD()

        func (e, r) =>
            if e
                deferred.reject()
            else
                deferred.resolve()

        return deferred.promise()