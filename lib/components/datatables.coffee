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
                render: ->
                    ret = ''
                render: (data) =>

                    ret = ''

                    for action in options.actions
                        ret += "<a href='#{option.prefix}#{data._id}/edit' class='action-#{action.type}'><i class='fa fa-#{action.icon}'></i> #{action.text}</a>"

                    ret
            }

        @[name] = new Tabular.Table options

    @InitTemplate: (template, table) ->

        helper = {}

        helper[table] = @[table]

        console.log helper
        template.helpers helper