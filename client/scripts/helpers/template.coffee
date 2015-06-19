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
        UI.registerHelper 'currentUser', ->
            new MeteorUser Meteor.user()

        UI.registerHelper 't', (msg) ->
            Helpers.Translation.Translate msg