Object.deleteProperty = (obj, property) ->
    obj[property] = null
    try
        delete obj[property]
    catch e
        glup = null

Object.byString = (obj, prop) ->

    return obj[prop] if prop.indexOf('.') is -1

    parts = prop.split('.')
    last = parts.pop()
    l = parts.length
    i = 1
    current = parts[0]

    while (obj = obj[current]) && i < l
        current = parts[i]
        i++

    if obj
        return obj[last]

    return null

Object.extendWith = (target, source) ->
    for own key, value of source
        target[key] = value

Object.isSameAs = (a, b) ->

    return false if Object.keys(a).length isnt Object.keys(b).length

    for own key, value of a
        return false if b[key] isnt value

    return true