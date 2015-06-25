@TabularTables = {}

class @TabularTables

    @_options = {}
    subscribeTemplates = []

    # Ensuring we log required translations
    Crater.startup ->
        translate 'commons.confirmation.delete_record'
        translate 'commons.edit'
        translate 'commons.view'
        translate 'commons.delete'
        translate 'commons.actions'
    , 1

    @Create = (name, options) =>

        options.actions ||= []

        if options.editable
            options.actions.push {
                text: translate 'commons.edit'
                icon: 'edit'
                type: 'edit'
                url: 'edit'
            }

        if options.viewable
            options.actions.push {
                text: translate 'commons.view'
                icon: 'eye'
                type: 'view'
                url: ''
            }

        if options.deletable
            options.actions.push {
                text: options.deleteText || translate 'commons.delete'
                icon: 'times-circle'
                type: 'delete'
                event: true
                callback: options.deleteCallback
                class: 'text-danger'
            }

        if options.actions
            options.columns.push {
                title: translate 'commons.actions'
                width: 100
                data: '_id'
                createdCell: (cell, data) =>

                    $cell = $ cell
                    $cell.empty()

                    for action in options.actions
                        a = $ "<a href='#{options.prefix}#{data}/#{action.url}' class='inline left5 right5 #{action.class} action-#{action.type}'><i class='fa fa-#{action.icon}'></i> #{action.text}</a>"
                        $cell.append a

                        deleteCallback = action.callback

                        if action.event
                            a.click (e) ->
                                e.preventDefault()
                                Helpers.Client.Notifications.Confirm translate('commons.confirmation.delete_record'), ->
                                    if deleteCallback
                                        deleteCallback(data)
                                    else
                                        options.collection.remove(data)
            }

        for column in options.columns
            if column.inlineEditable
                column.createdCell = (cell, data, row) =>
                    $cell = $ cell

                    input = $ '<input type="text" class="form-control block full-width" />'
                    input.hide().val(data)

                    content = $ '<div>' + data + '</div>'

                    $cell.empty().append(content).append(input).addClass('pointer')

                    Helpers.Client.DOM.OnEnterKey input, =>

                        translation = options.collection.update {
                                _id: row._id
                        }, {
                            $set: {
                                value: $.trim(input.val())
                            }
                        }

                        input.hide()
                        content.show()

                    $cell.click ->
                        input.show().focus()
                        content.hide()


        @_options[name] = options
        @[name] = new Tabular.Table options

    @InitTableHelper: (template, table) =>

        helper = {}

        helper[table] = @[table]

        template.helpers helper