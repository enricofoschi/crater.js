class @Translation extends BaseCollection
    # indicate which collection to use
    @_collection: new Mongo.Collection('translations')

    @schema: {
        key:
            type: String
            label: 'Translation Key'
            max: 100
        route:
            type: String
            label: 'Translation Route'
            max: 100
            optional: true
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
            Meteor.settings?.debug || Roles.userIsInRole userId, ['admin']
        update: (userId, doc) ->
            Meteor.settings?.debug || Roles.userIsInRole userId, ['admin']
        remove: (userId, doc) ->
            Meteor.settings?.debug || Roles.userIsInRole userId, ['admin']
    }

Crater.startup( ->

    if Meteor.isServer
        Translation._collection._ensureIndex {
            route: 1
        }
        Translation._collection._ensureIndex {
            language: 1
        }
)