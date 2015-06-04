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

    @UpdateFreeBusy: (interview, calendars, config, callback) =>

        userId = Meteor.userId()

        InterviewScheduler.Collections.TimeSlot.destroyAll {
            user_id: userId
        }

        @List (error, list) =>

            if error
                throw error

            calendars = {}

            for calendar in list
                calendars[calendar.id] = InterviewScheduler.Collections.Calendar.first({
                    calendar_id: calendar.id
                }).id

            @FreeBusy config.startDate, config.endDate, _.map(list, (l) -> l.id), (error, data) =>

                if error
                    throw error

                for own key, calendar of data.calendars

                    for slot in calendar.busy

                        start = new Date(slot.start)
                        end = new Date(slot.end)

                        InterviewScheduler.Collections.TimeSlot.create {
                            user_id: userId
                            calendar_id: calendars[key]
                            start: start
                            end: end
                            start_int: start.getTime() / GlobalSettings.timeslotDivider
                            end_int: end.getTime() / GlobalSettings.timeslotDivider
                        }

                callback()