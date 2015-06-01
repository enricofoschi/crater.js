class @Helpers.Client.TemplatesHelper

    @Handle: (name) ->

        template = Template[name]

        template.created = ->
            template.instance = template.instance || Template.instance()

        template.helpers {
            'currentUser': ->
                new MeteorUser Meteor.user()
        }

        template