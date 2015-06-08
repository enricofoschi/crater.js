class @Helpers.Client.Loader

    blocker = null

    activeLoaders = 0

    @Init: ->
        if not blocker
            blocker = $ '.blocker-container'

    @Show:  ->

        @Init()

        if not activeLoaders and blocker
            blocker.stop(true, false).fadeIn(250)

        activeLoaders++

        return

    @Hide: ->

        activeLoaders--

        if not activeLoaders and blocker
            blocker.stop(true, false).fadeOut(250)

        return