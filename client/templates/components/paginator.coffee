Helpers.Client.TemplatesHelper.Handle('paginator', (template) =>

    getPages = (options) ->
        Math.ceil(options.total / options.size)

    getUrl = (options, page) ->
        if options.path
            return Helpers.Router.Path(options.path, _.extend options.params, {
                page: parseInt(page)
            })
        return null

    template.helpers({

        hasPaging: ->
            pages = getPages(@options)

            return pages > 1

        pages: ->
            pages = getPages(@options)

            min = @options.page - 3
            min = 1 if min < 1

            max = @options.page + 3
            max = pages if max > pages

            return (i for i in [min..max])

        pageUrl: (options) ->
            return getUrl(options, @)

        previousUrl: ->
            return getUrl(@options, @options.page - 1)

        previousPage: ->
            return @options.page - 1

        nextUrl: ->
            getUrl(@options, @options.page + 1)

        nextPage: ->
            return @options.page + 1

        hasPrevious: ->
            return @options.page > 1

        hasNext: ->
            pages = getPages(@options)

            return @options.page < pages

        isSelected: (options) ->
            return parseInt(@) is options.page
    })

    template.events({
        'click a': (event, instance) ->
            if instance.data.options.callback

                page = parseInt($(event.target).attr('data-page') || @)

                instance.data.options.callback(page)
                event.preventDefault()
    })

)