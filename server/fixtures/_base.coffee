@Fixture = {}

class @Fixture.Base

    @_collection: null
    @_data: null,
    @_uniqueFilter: null

    @Ensure: ->

        for attr in @_data
            found = @_collection.findOne(@_uniqueFilter attr)

            if not found
                console.log 'Creating:'
                console.log attr
                @_create attr

    @_create: (attr) ->
        @_collection.insert attr


Meteor.startup =>
    BaseCollection.InitCollections()

    for own key, value of @Fixture
        if key is 'Base'
            continue
        @Fixture[key].Ensure()

