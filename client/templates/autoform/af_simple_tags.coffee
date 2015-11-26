Helpers.Client.TemplatesHelper.Handle('AutoForm_SimpleTags', (template) =>

    template.events {
        'click .btn-remove': (e) ->

            currentInstance = Template.instance()

            source = $(e.target).parents 'li:first'
            list = source.parent()
            source.remove()
            currentInstance.data.atts.properties.onRemove list

    }

)

Crater.startup ->
    AutoForm.addInputType 'simple-tags', {
        template: 'AutoForm_SimpleTags'
        valueOut: ->
            @
    }