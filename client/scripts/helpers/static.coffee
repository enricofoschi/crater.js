class @Helpers.Client.Static

    StaticContent = new Mongo.Collection 'static_collection'

    @IncludeContent: (identifier) ->
        StaticContent.findOne(identifier)?.content
