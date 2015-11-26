class @Helpers.Google

    @GetLatLonFromLocation: (location) ->
        if not location
            return {
                lat: null
                lon: null
            }

        lat = null
        lon = null

        for own key, value of location
            if not lat
                lat = value
            else if not lon
                lon = value
            else
                continue

        {
            lat: lat
            lon: lon
        }
