class @Helpers.Client.TemplatesHelper

    serverSettings = new ReactiveVar()

    @Handle: (name) ->

        template = Template[name]

        template.serverSettings = serverSettings

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

        Helpers.Client.MeteorHelper.CallMethod {
            method: 'getClientSettings'
            params: []
            callback: (e, r) ->
                if not e and r
                    serverSettings.set r
        }

