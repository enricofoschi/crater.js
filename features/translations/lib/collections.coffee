class @Translation extends BaseCollection
    # indicate which collection to use
    @_collection: new Mongo.Collection('translations')

    @schema: ->
        {
        key:
            type: String
            label: 'Translation Key'
            max: 100
        routes:
            type: [Object]
            label: 'Translation Routes'
            optional: true
            blackbox: true
        lang:
            type: String
            label: 'Language'
            max: 2
        common:
            type: Boolean
            label: 'Common to all pages'
            optional: true
        value:
            type: String
            label: 'Value'
            optional: true
        }

    @_collection.allow {
        insert: (userId, doc) ->
            Roles.userIsInRole userId, ['admin']
        update: (userId, doc) ->
            Roles.userIsInRole userId, ['admin']
        remove: (userId, doc) ->
            Roles.userIsInRole userId, ['admin']
    }

BaseCollection.InitCollections()

Meteor.startup ->
    if Meteor.isServer
        Translation._collection._ensureIndex {
            'routes.name': 1
        }
        Translation._collection._ensureIndex {
            language: 1
        }
