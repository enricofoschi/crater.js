class @Helpers.Time

    getMoment = ->
        if Meteor.isClient
            moment
        else
            Meteor.npmRequire 'moment'

    @GetYearsDifference: (year, month, day = 1) =>
        moment = getMoment()

        date = new Date(year, month || 0, day)

        diff = moment(new Date()).diff(date, 'years')

        diff

    @GetNearestDayOfWeek = (weekDates, retroactive = false, hours = 10) ->
        moment = getMoment()

        nearest = null
        current = moment()

        for weekDate in weekDates || []
            dateToCheck = moment().day weekDate
            daysDiff = current.diff(dateToCheck, 'days')
            if daysDiff < 0

                if not nearest and retroactive
                    nearest = moment().day(-7 + weekDate)

                break
            else
                nearest = dateToCheck

        nearest = nearest.startOf('day').hours(hours).toDate() if nearest

        nearest

    @GetLocalDateISOString: =>
        currentDate = new Date()
        timezoneOffset = currentDate.getTimezoneOffset() * 60 * 1000

        localDate = new Date(currentDate.getTime() - timezoneOffset)
        localDateISOString = localDate.toISOString().replace('Z', '')
        return localDateISOString
