globalContext = @

class @Helpers.Promises

    @FromSubscription: (subscription, options...) =>
        deferred = $.Deferred()

        options ||= []

        options.push {
            onReady: ->
                deferred.resolve()
            onError: ->
                deferred.reject()
        }

        options.unshift subscription

        Meteor.subscribe.apply @, options

        return deferred.promise()

    @FromFunction: (func) =>
        deferred = $.DeferreD()

        func (e, r) =>
            if e
                deferred.reject()
            else
                deferred.resolve()

        return deferred.promise()