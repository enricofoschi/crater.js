Date::UTCFromLocal = () ->
    utc = new Date @
    utc.setMinutes utc.getMinutes() + utc.getTimezoneOffset()
    return utc

Date::addDays = (days) ->
    dat = new Date(@valueOf())
    dat.setDate(dat.getDate() + days)
    dat

Date::addSeconds = (seconds) ->
    dat = new Date(@valueOf())
    dat.setSeconds(dat.getSeconds() + seconds)
    dat

Date::resetTime = ->
    @setMinutes 0
    @setHours 0
    @setSeconds 0
    @setMilliseconds 0
    @

Date::toUIFormat = (withTime) ->
    date = moment(@)

    if withTime
        return date.format('ddd DD MMM YYYY HH:mm')
    else
        return date.format('ddd DD MMM YYYY')

Date.ES_FORMAT_KIBANA = 'yyyy/MM/dd HH:mm:ss' # kibana format
Date.ES_FORMAT_MOMENTJS = 'YYYY/MM/DD HH:mm:ss' # momentjs format

Date::toESFormat = ->
    moment(@).format(Date.ES_FORMAT_MOMENTJS)

Date::isDate = true