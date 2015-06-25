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

    @FromSyncFunction: (func) =>

        deferred = $.Deferred()

        func()
        deferred.resolve()

        return deferred.promise()

    @FromAsyncFunction: (func) =>
        deferred = $.Deferred()

        func (e, r) =>
            if e
                deferred.reject()
            else
                deferred.resolve()

        return deferred.promise()

    @RunInSequence: (promises) =>
        deferred = $.Deferred()

        promisesByPriorityObj = _.groupBy(promises, (c) -> c.priority)
        promisesByPriorityList = []

        for own key, value of promisesByPriorityObj
            promisesByPriorityList.push _.map(value, (p) -> p.promise)

        currentIndex = 0

        runPromises = =>
            Helpers.Log.Info 'Running priorities: ' + currentIndex

            $.when.apply($, promisesByPriorityList[currentIndex]).done(=>
                currentIndex++;
                if promisesByPriorityList[currentIndex]
                    runPromises()
                else
                    deferred.resolve()
            )

        runPromises()

        return deferred.promise()