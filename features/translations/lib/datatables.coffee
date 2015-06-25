Crater.startup ->
    TabularTables.Create 'Translations', {
        name: "TranslationsList"
        collection: Translation._collection,
        prefix: '/admin/translation/'
        pageLength: 25
        dom: '<f<t>pi>'
        deletable: true
        viewable: true
        deleteText: translate 'commons.remove'
        columns: [
            {
                data: "key"
                title: translate "commons.translations.key"
            }
            {
                data: "value"
                title: translate "commons.translations.value"
                inlineEditable: true
            }
            {
                data: "route"
                title: translate "commons.translations.found_in"
                createdCell: (td, data, row) ->
                    $td = $ td

                    link = data

                    if Router.routes[data]
                        link = '<a href="' + Helpers.Router.Path(Router.routes[data]) + '">' + data + '</a>'

                    $td.empty().html link
            }
        ]
    }