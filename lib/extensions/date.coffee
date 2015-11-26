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

Date.ES_FORMAT = 'yyyy/MM/dd HH:mm:ss'

Date::toESFormat = ->
    moment(@).format('YYYY/MM/DD HH:mm:ss')

Date::isDate = true