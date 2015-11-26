class @Crater.Collections.Error extends BaseCollection

    # indicate which collection to use
    @_collection: new Mongo.Collection('errors')

    @schema: ->
        {
            data:
                type: Object
                blackbox: true
        }
