class @Crater.Api.Google.Event extends Crater.Api.Google.Base

    createEvent: (userId, calendarId, options, callback) =>

        options.custom = {
            user: userId
        }

        @Call 'post', 'calendar/v3/calendars/' + encodeURIComponent(calendarId) + '/events', options, (err, response) ->
            if err
                throw err
            else
                callback null, response.data

    getEvent: (userId, calendarId, eventId, callback) =>

        options = {
            custom:
                user: userId
        }

        url = 'calendar/v3/calendars/' + encodeURIComponent(calendarId) + '/events/' + encodeURIComponent(eventId)

        @Call 'get', url, options, callback

    deleteEvent: (userId, calendarId, eventId, callback) =>

        options = {
            custom:
                user: userId
        }

        url = 'calendar/v3/calendars/' + encodeURIComponent(calendarId) + '/events/' + encodeURIComponent(eventId) + '?sendNotifications=true'

        @Call 'delete', url, options, callback