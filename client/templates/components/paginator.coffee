Helpers.Client.TemplatesHelper.Handle('paginator', (template) =>

    getPages = (options) ->
        Math.ceil(options.total / options.size)

    getUrl = (options, page) ->
        Helpers.Router.Path options.path, _.extend options.params, {
            page: parseInt(page)
        }

    template.helpers {

        hasPaging: ->
            pages = getPages @options

            pages > 1


        pages: ->
            pages = getPages @options

            min = @options.page - 3
            min = 1 if min < 1

            max = @options.page + 3
            max = pages if max > pages

            (i for i in [min..max])

        pageUrl: (options) ->
            getUrl options, @

        previousUrl: ->
            getUrl @options, @options.page - 1

        nextUrl: ->
            getUrl @options, @options.page + 1

        hasPrevious: ->
            @options.page > 1

        hasNext: ->
            pages = getPages @options

            @options.page < pages

        isSelected: (options) ->
            parseInt(@) is options.page
    }

)