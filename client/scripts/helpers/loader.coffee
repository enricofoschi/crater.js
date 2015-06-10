class @Helpers.Client.Loader

    blocker = null

    activeLoaders = 0

    @Init: ->
        if not blocker
            blocker = $ '.blocker-container'

    @Reset: ->
        activeLoaders = 0

    @Show:  ->

        @Init()

        if not activeLoaders and blocker
            blocker.stop(true, false).fadeIn(250)

        activeLoaders++

        return

    @Hide: ->

        if activeLoaders > 0
            activeLoaders--

        if not activeLoaders and blocker
            blocker.stop(true, false).fadeOut(250)

        return