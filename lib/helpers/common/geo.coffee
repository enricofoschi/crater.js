class @Helpers.Geo

    @GetDistanceFromLatLon: (pointA, pointB) =>
        R = 6371

        pointA.lat = parseInt(pointA.lat)
        pointA.lon = parseInt(pointA.lon)
        pointB.lat = parseInt(pointB.lat)
        pointB.lon = parseInt(pointB.lon)

        rad1 = pointA.lat.toRad()
        rad2 = pointB.lat.toRad()

        deltaLatRad = (pointB.lat - pointA.lat).toRad()
        deltaLonRad = (pointB.lon - pointA.lon).toRad()

        a = Math.pow(Math.sin(deltaLatRad / 2), 2) + Math.cos(rad1) * Math.cos(rad2) * Math.pow(Math.sin(deltaLonRad / 2), 2)
        c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
        R * c

