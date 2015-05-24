class @Helpers.Client.Loader

    blocker = null

    @Init: ->
        if not blocker
            blocker = $ '.blocker-container'

    @Show:  ->

        @Init()

        if blocker
            blocker.stop(true, false).fadeIn(500)

        return

    @Hide: ->

        if blocker
            blocker.stop(true, false).fadeOut(500)

        return