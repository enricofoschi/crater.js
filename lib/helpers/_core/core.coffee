@Helpers = {
    Client: {},
    Server: {}
}
Global = @

class @Helpers.Core

    @ensure: (pathToEnsure) ->

        pathContainer = Global

        for part in pathToEnsure.split '.'
            pathContainer = pathContainer[part] ?= {}

        pathContainer

