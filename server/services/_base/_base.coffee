globalContext = @
class @Crater.Services

    services = {}

    @Init: (properties) ->
        if services[properties.key]
            return

        services[properties.key] = properties.service()

    @Get: (properties) ->
        services[properties.key]

    @InitAll: =>
        for own key, value of globalContext.Services
            @Init value

    @Set: (properties, service) ->
        services[properties.key] = properties.service()

    class @Base
