globalContext = @

class @Helpers.Client.Google

    placesApiPromise = null

    @LoadPlacesAPI: (callback) =>

        if placesApiPromise
            placesApiPromise.then callback
        else
            deferred = $.Deferred()
            globalContext.initGoogleMaps = ->
                deferred.resolve()
            placesApiPromise = deferred.promise()
            deferred.then callback
            $.getScript 'https://maps.googleapis.com/maps/api/js?v=3.exp&libraries=places&callback=initGoogleMaps'

    @InitLocationAutocomplete: (input, callback, types=['(cities)']) =>

        if not input
            return

        orginalValue = input.value

        $input = $ input

        if $input.data 'autocomplete-initialized'
            return

        $input.data 'autocomplete-initialized', true

        @LoadPlacesAPI ->

            properties = {}
            if types
                properties.types = types

            autocomplete = new google.maps.places.Autocomplete(input, properties)

            input.value = orginalValue
            $input = $(input)

            $input.keydown (e) ->
                if e.which is 9
                    google.maps.event.trigger autocomplete, 'place_changed'

            google.maps.event.addListener autocomplete, 'place_changed', ->

                place = autocomplete.getPlace()

                if place?.formatted_address
                    $input.data('google-place', place)

                    # fixing lat / lon
                    if typeof(place?.geometry?.location?.lat) is 'function'
                        place.geometry.location.lat = place.geometry.location.lat()
                        place.geometry.location.lng = place.geometry.location.lng()

                    if callback
                        callback place
                else
                    window.setTimeout ->
                        $input.val('')
                    , 100