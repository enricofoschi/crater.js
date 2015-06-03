class @Crater.Api.Google.Calendar extends Crater.Api.Google.Base

    @List: (callback) =>
        @Call 'get', 'calendar/v3/users/me/calendarList', {}, (error, result) ->
            if error
                throw error
            else
                callback null, result.data.items

    @FreeBusy: (from, to, calendars, callback) =>

        @Call 'post', 'calendar/v3/freeBusy', {
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

    @UpdateFreeBusy: (config, timesToCheck, callback) ->

        startDate = config.startDate
        endDate = config.endDate

        Crater.Api.Google.Calendar.FreeBusy startDate, endDate, [
            'enrico.foschi@rocket-internet.de'
        ], (error, data) ->

            userId = Meteor.userId()

            for own key, calendar of data.calendars
                for slot in calendar.busy

                    start = new Date(slot.start)
                    end = new Date(slot.end)

                    InterviewScheduler.Collections.TimeSlot.create {
                        user_id: userId
                        calendar_id: key
                        start_int: start.getTime() / 1000 / 60
                        end_int: start.getTime() / 1000 / 60
                    }

            callback()