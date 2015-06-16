class @Crater.Services

    services = {}

    @Init: (properties) ->
        services[properties.key] = properties.service()

    @Get: (properties) ->
        services[properties.key]

    class @Base
