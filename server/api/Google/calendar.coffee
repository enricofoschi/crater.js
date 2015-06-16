class @Crater.Api.Google.Calendar extends Crater.Api.Google.Base

    List: (userId, callback) =>
        @Call 'get', 'calendar/v3/users/me/calendarList', {
            custom:
                user: userId
        }, (error, result) ->
            if error
                throw error
            else
                callback null, result.data.items

    FreeBusy: (userId, from, to, calendars, callback) =>

        @Call 'post', 'calendar/v3/freeBusy', {
            custom:
                user: userId
            data:
                timeMin: from.toISOString()
                timeMax: to.toISOString()
                timeZone: 'UTC'
                items: _.map calendars, (c) -> {id: c}
        }, (err, response) ->
            if err
                throw err
            else
                callback null, response.data

    GetFreeBusy: (userId, calendars, config, callback) =>

        @FreeBusy userId, config.startDate, config.endDate, Object.keys(calendars), (error, data) =>

            if error
                throw error

            timeSlots = []

            for own key, calendar of data.calendars

                for slot in calendar.busy

                    start = new Date(slot.start)
                    end = new Date(slot.end)

                    timeSlots.push {
                        user_id: userId
                        calendar_id: calendars[key]
                        start_int: start.getTime() / GlobalSettings.timeslotDivider
                        end_int: end.getTime() / GlobalSettings.timeslotDivider
                    }

            callback(null, timeSlots)