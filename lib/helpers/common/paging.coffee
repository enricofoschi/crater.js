class @Helpers.Paging

    @SanitizePage: (list, size, page) ->
        pages = Math.ceil list.length / size

        page = 1 if page < 1
        page = pages if page > pages and pages > 0

        page