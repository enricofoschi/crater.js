class @Helpers.Google

    cachedQueries = []

    @GetGeocodedLocation: (address) ->
        logServices = Crater.Services.Get Services.LOG

        # Getting from cached queries
        geocodedLocation = _.find(cachedQueries, (q) ->
            q.address is address.toLowerCase()
        )?.location

        # Getting from Google
        if not geocodedLocation

            # Sleep to avoid getting our IP banned for the too many queries
            Meteor.sleep 0.5 * Math.random()

            logServices.Info 'Getting geocode for ' + address
            response = Meteor.http.get('https://maps.googleapis.com/maps/api/geocode/json?address=' + encodeURIComponent(address))
            results = JSON.parse(response.content).results

            if results.length
                geocodedLocation = results[0]

                geocodedLocation.formatted_address = geocodedLocation.formatted_address.replace(/^([0-9]+ )?/, '')

                cachedQueries.push {
                    address: address.toLowerCase()
                    location: geocodedLocation
                }

        geocodedLocation

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
