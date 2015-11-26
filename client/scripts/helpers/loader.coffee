class @Helpers.Client.Loader

    blocker = null
    msgContainer = null
    forced = false
    activeLoaders = 0

    @Msg: (msg) ->
        if msgContainer
            msgContainer.text msg
            msgContainer.show()

    @IsActive: -> activeLoaders > 0

    @Init: ->
        if not blocker or not blocker.length
            blocker = $ '.blocker-container'
            msgContainer = blocker.find '.msg-container'

    @Reset: ->
        activeLoaders = 0
        @Hide true
        blocker = null

    @Show: (force)  ->

        @Init()

        Helpers.Log.Info 'Active Loaders: ' + activeLoaders
        Helpers.Log.Info 'Loader: ' + blocker.length

        if force
            forced = force

        if not activeLoaders and blocker.length
            Helpers.Log.Info 'Loader On'
            blocker.stop(true, false).fadeIn(250)

        activeLoaders++

        return

    @Hide: (force) ->

        if forced and not force
            return

        forced = false

        if activeLoaders > 0
            activeLoaders--

        if activeLoaders is 0 and blocker?.length
            msgContainer.hide()
            Helpers.Log.Info 'Loader Off'
            blocker.stop(true, false).fadeOut(250)

        return