class @Crater.Collections.Email extends NamedCollection

    # indicate which collection to use
    @_collection: new Mongo.Collection('emails')
    @langs = ServerSettings.languages

    @schema: ->
        {
            template:
                type: String
            data:
                type: Object
                blackbox: true
            to:
                type: String
        }

    @_collection.allow {
        insert: (userId, doc) ->
            Roles.userIsInRole userId, ['admin']
        update: (userId, doc) ->
            Roles.userIsInRole userId, ['admin']
        remove: (userId, doc) ->
            Roles.userIsInRole userId, ['admin']
    }