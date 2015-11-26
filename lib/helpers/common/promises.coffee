globalContext = @

class @Helpers.Promises

    @FromSubscription: (subscription, paramsGetter) =>
        =>
            deferred = $.Deferred()

            options = paramsGetter() || []

            options.push {
                onReady: ->
                    deferred.resolve()
                onError: ->
                    deferred.reject()
            }

            options.unshift subscription

            subManager.subscribe.apply @, options

            return deferred.promise()

    @FromSyncFunction: (func) =>

        if func.done
            return func

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

            promisesToRun = _.map(promisesByPriorityList[currentIndex], (p) ->
                if p.done
                    return p
                else
                    return p()
            )

            $.when.apply($, promisesToRun).done(=>
                currentIndex++;
                if promisesByPriorityList[currentIndex]
                    runPromises()
                else
                    deferred.resolve()
            )

        runPromises()

        return deferred.promise()

    _waitOnPromises = {}
    @FromPromisesToWaitOnHandle: (name, promises) =>

        _waitOnPromises[name] = {
            promises: promises
            ready: false
            readyDeps: new Deps.Dependency
        }

        $.when.apply(@, promises).done =>
            _waitOnPromises[name].ready = true
            _waitOnPromises[name].readyDeps.changed()

        handle = {
            ready: =>
                _waitOnPromises[name].readyDeps.depend()
                _waitOnPromises[name].ready
        }

        return handle