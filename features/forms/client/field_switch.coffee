Helpers.Client.TemplatesHelper.Handle('AutoForm_FieldSwitch', (template) =>

    randomId = null

    template.onCustomCreated = =>
        randomId = 'switch_' + Math.round(Math.random() * 100000)
        $('.onoffswitch-label').click(->
            $(@).parent().toggleClass('onoffswitch-checked')
        )

    template.helpers {
        'randomId': ->
            randomId
    }

)

Crater.startup ->
    AutoForm.addInputType 'switch', {
        template: 'AutoForm_FieldSwitch'
        valueOut: ->
            @checked
    }