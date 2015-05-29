@TabularTables = {}

class @TabularTables

    @Create = (name, options) ->

        options.actions ||= []

        if options.editable
            options.actions.push {
                text: 'Edit'
                icon: 'edit'
                type: 'edit'
            }

        if options.removable
            options.actions.push {
                text: 'Remove'
                icon: 'times-circle'
                type: 'remove'
            }

        if options.actions
            options.columns.push {
                title: 'Actions'
                width: 100
                data: '_id'
                render: ->
                    ret = ''
                render: (data) =>

                    ret = ''

                    for action in options.actions
                        ret += "<a href='#{options.prefix}#{data}/edit' class='action-#{action.type}'><i class='fa fa-#{action.icon}'></i> #{action.text}</a>"

                    ret
            }

        @[name] = new Tabular.Table options

    @InitTemplate: (template, table) ->

        helper = {}

        helper[table] = @[table]
        template.helpers helper