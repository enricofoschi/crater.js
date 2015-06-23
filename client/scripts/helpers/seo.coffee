class @Helpers.Client.SEO

    pageProperties = new ReactiveDict 'pageProperties'
    pageProperties.set 'title', ''

    @SetTitle: (title) ->
        pageProperties.set 'title', title

    Crater.startup ->
        Tracker.autorun =>
            document.title = pageProperties.get 'title'