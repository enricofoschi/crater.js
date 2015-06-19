Global = @

class @Helpers.Client.MeteorHelper

    @CallMethod: (properties) ->

        callback = (errors, results) ->
            Helpers.Client.Loader.Hide()
            if properties.callback
                properties.callback errors, results

        Helpers.Client.Loader.Show()

        Global.Meteor.apply properties.method, properties.params || [], callback