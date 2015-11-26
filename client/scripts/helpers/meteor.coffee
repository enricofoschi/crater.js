class @Helpers.Client.MeteorHelper

    # Ensuring translations
    Meteor.startup ->
        Helpers.Translation.OnCommonTranslationsLoaded ->
            translate('commons.communication.method_error')

    @CallMethod: (properties) ->

        Helpers.Log.Info 'Called method: ' + properties.method

        originalArguments = properties

        callback = (errors, results) ->
            if not properties.background
                if not properties.blockUntilDataRefresh
                    Helpers.Client.Loader.Hide()

            if errors

                if ServerSettings?.debug
                    Helpers.Log.Error originalArguments
                    Helpers.Client.Notifications.Error errors
                else if not properties.background
                    Helpers.Client.Notifications.Error translate('commons.communication.method_error')

            if properties.callback
                properties.callback errors, results

        if not properties.background
            Helpers.Client.Loader.Show()
            if properties.loadingMsg
                Helpers.Client.Loader.Msg properties.loadingMsg

        if properties.waitOnRefreshData
            MeteorHelper.UntilNextRefresh properties.refreshDataGetter, =>
                if properties.blockUntilDataRefresh and not properties.background
                    Helpers.Client.Loader.Hide()
                properties.onDataRefresh()

        Meteor.apply properties.method, properties.params || [], callback

    @UntilNextRefresh: (getter, callback) ->
        initialised = false

        tracker = Tracker.autorun ->
            if initialised
                callback()
                tracker.stop()

            getter() # subscribing
            initialised = true

    MIN_SUBSCRIPTION_RESULTS = 2

    getCachedSubscriptionKey = (identifier) =>
        'sub_' + identifier + '_' + + ServerSettings.version

    @SubscribeIfNotCached: (subscriptions, identifier, subscription, args) =>
        if not (Helpers.Client.Storage.GetCache(getCachedSubscriptionKey(identifier))?.length > MIN_SUBSCRIPTION_RESULTS)
            Helpers.Log.Info 'Subscribing to ' + identifier
            subscriptions.push(
                subManager.subscribe.apply subManager, [subscription].concat(args || [])
            )

    @GetCachedSubscribedData: (identifier, collection) =>
        stored = Helpers.Client.Storage.GetCache getCachedSubscriptionKey(identifier)
        if stored?.length > MIN_SUBSCRIPTION_RESULTS
            Helpers.Log.Info 'Ret cached ' + identifier, stored.length
            return stored
        else
            data = collection.all()
            data = _.map data, (d) ->
                r = _.extend {}, d
                r._id = d._id
                if typeof d._id is 'object'
                    r._id = d._id._str
                    r.id = r._id
                r
            Helpers.Client.Storage.SetCache getCachedSubscriptionKey(identifier), data, 60 * 60 * 24 * 3
            Helpers.Log.Info 'Cached ' + identifier, data.length
            return data