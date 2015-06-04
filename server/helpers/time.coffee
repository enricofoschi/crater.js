class @Helpers.Server.Time

    @GetWorkingDaysTimeSlots: (startDate, daysToCheck, startHour, endHour, startMinute, endMinute, duration) ->
        timesToCheck = []
        extraDay = 0;

        start = new Date()
        start.setHours(startHour, startMinute, 0, 0)
        end = new Date()
        end.setHours(endHour, endMinute, 0, 0)

        steps = (end - start) / 1000 / 60 / 30

        while daysToCheck > 0

            currentDate = new Date(startDate)
            currentDate.setDate(startDate.getDate() + extraDay)
            extraDay++

            dateStr = currentDate.getDate()+'/' + (currentDate.getMonth() + 1)
            weekDay = currentDate.getDay()

            if weekDay is 0 or weekDay is 6 or (Meteor.settings.holidays and _.find(Meteor.settings.holidays, (i) -> i is dateStr))
                continue

            for step in [0...steps]
                stepDate = new Date(currentDate)
                stepDate.setHours(startHour, startMinute + step * 30)

                start = stepDate.getTime() / GlobalSettings.timeslotDivider

                timesToCheck.push({
                    start: start
                    end: start + duration
                })

            daysToCheck--

        timesToCheck
