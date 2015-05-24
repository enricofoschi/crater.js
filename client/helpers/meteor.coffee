Global = @

class @Helpers.Client.Meteor

    @CallMethod: (method, params..., callback) ->

        if callback
            if typeof callback is 'function'

                finished = callback

                callback = (errors, results) ->
                    Helpers.Client.Loader.Hide()
                    finished errors, results
            else
                params.push callback
        else
            callback = ->
                Helpers.Client.Loader.Hide()

        Helpers.Client.Loader.Show()
        Global.Meteor.apply method, params, callback