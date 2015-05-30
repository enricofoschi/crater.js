@TabularTables = {}

class @TabularTables

    @_options = {}

    @Create = (name, options) ->

        options.actions ||= []

        if options.editable
            options.actions.push {
                text: 'Edit'
                icon: 'edit'
                type: 'edit'
            }

        if options.deletable
            options.actions.push {
                text: 'Delete'
                icon: 'times-circle'
                type: 'delete'
                event: (_id) ->
                    console.log _id
                class: 'text-danger'
            }

        if options.actions
            options.columns.push {
                title: 'Actions'
                width: 100
                data: '_id'
                createdCell: (cell, data) =>

                    $cell = $ cell
                    $cell.empty()

                    for action in options.actions
                        a = $ "<a href='#{options.prefix}#{data}/#{action.type}' class='left5 right5 #{action.class} action-#{action.type}'><i class='fa fa-#{action.icon}'></i> #{action.text}</a>"
                        $cell.append a

                        if action.event
                            a.click (e) ->
                                e.preventDefault()
                                Helpers.Client.Notifications.Confirm 'Do you really want to delete this record?', ->
                                    options.collection.remove(data)
            }


        @_options[name] = options
        @[name] = new Tabular.Table options

    @InitTemplate: (template, table) ->

        helper = {}

        helper[table] = @[table]
        template.helpers helper