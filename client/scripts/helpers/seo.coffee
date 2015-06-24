class @Helpers.Client.SEO

    pageProperties = new ReactiveDict 'pageProperties'
    pageProperties.set 'title', ''

    @SetTitle: (title) ->
        pageProperties.set 'title', title

    @GetTitle: (title) ->
        pageProperties.get 'title', title

    Crater.startup ->
        Tracker.autorun =>
            document.title = pageProperties.get 'title'