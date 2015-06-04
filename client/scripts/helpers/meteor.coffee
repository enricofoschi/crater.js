Global = @

class @Helpers.Client.MeteorHelper

    @CallMethod: (method, params..., callback) ->

        if callback
            if typeof callback is 'function'

                finished = callback

                callback = (errors, results) ->
                    Helpers.Client.Loader.Hide()
                    finished errors, results
            else
                params.push callback
                callback = ->
                    Helpers.Client.Loader.Hide()
        else
            callback = ->
                Helpers.Client.Loader.Hide()

        Helpers.Client.Loader.Show()
        Global.Meteor.apply method, params, callback