class @Helpers.Client.SEO

    pageProperties = new ReactiveDict 'pageProperties'
    pageProperties.set 'title', ''

    @SetTitle: (title) ->
        suffix = ''
        suffix = ' - ' + ServerSettings.titleSuffix if (title.toLowerCase().indexOf(ServerSettings.titleSuffix.toLowerCase()) is -1)

        pageProperties.set 'title', title + suffix

    @GetTitle: (title) ->
        pageProperties.get 'title', title

    @SetDescription: (str) ->
        pageProperties.set 'description', str

    @GetDescription: (title) ->
        pageProperties.get 'description', str

    @SetImage: (str) ->
        pageProperties.set 'image', str

    @GetImage: (title) ->
        pageProperties.get 'image', str

    Crater.startup ->
        Tracker.autorun =>

            seoTitle        = pageProperties.get('title') ||  ServerSettings.titleSuffix
            seoDescription  = pageProperties.get('description') ||  ''
            seoImage        = pageProperties.get('image') || window.ServerSettings.urls.imgs + 'meta/facebook.jpg'

            document.title = seoTitle

            $('meta[name=description]').attr('content', seoDescription)

            $('meta[property="og:title"]').attr('content', seoTitle)
            $('meta[property="og:description"]').attr('content', seoDescription)
            $('meta[property="og:image"]').attr('content', seoImage)

            $('meta[property="og:url"]').attr('content', window.location.href.replace('___isRunningPhantomJS___=true', ''))
