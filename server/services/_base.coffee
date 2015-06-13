# TODO Implement Dependency Injection pettern and service configuration initialiser

class @Crater.Services

    services = {}

    @Init: (name, initialization) ->
        services[name] = initialization()

    @Get: (name) ->
        services[name]

    class @Base
