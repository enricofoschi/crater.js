class @Helpers.Client.TemplatesHelper

    @Handle: (name) ->

        template = Template[name]

        template.created = ->

            Helpers.Client.Loader.Reset()

            template.currentInstance = Template.instance()

            if template.onCustomCreated
                template.onCustomCreated()

        template

    @DecorateTemplates: =>
        Template.registerHelper 'currentUser', ->
            new MeteorUser Meteor.user()

        Template.registerHelper '_', (msg) ->
            Helpers.Translation.Translate msg