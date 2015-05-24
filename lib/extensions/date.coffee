Date::UTCFromLocal = () ->
    utc = new Date @
    utc.setMinutes utc.getMinutes() + utc.getTimezoneOffset()
    return utc