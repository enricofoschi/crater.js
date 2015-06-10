class @Helpers.Client.TemplatesHelper

    @Handle: (name) ->

        template = Template[name]

        template.created = ->

            Helpers.Client.Loader.Reset()

            template.currentInstance = Template.instance()

            if template.onCustomCreated
                template.onCustomCreated()

        template.helpers {
            'currentUser': ->
                new MeteorUser Meteor.user()
        }

        template