Array::any = (f) ->
    (return true if f x) for x in @
    return false

Array::remove = (f) ->
    (x for x in @ when not f x)

Array::present = ->
    @length > 0

Array::toMatrix = (max) ->
    matrix = []

    max = if max > 0 then max else 2

    index = max

    while index < @.length + max
        matrix.push (x for x, i in @ when i >= index - max and i < index)
        index += max

    matrix

Array::equalTo = (arr) ->

    arr ||= []

    return false if @length isnt arr.length

    for el, index in @
        return false if not Object.isSameAs el, arr[index]

    return true

Array::getPage = (page, size) ->
    page = Helpers.Paging.SanitizePage @, size, page

    start = size * (page - 1)
    if start + size > @length then end = @length else end = start + size

    @[start..end]

Array::fromObj = (obj) ->

    for own key,value of obj
        @push {
            key: key
            value: value
        }

Array::splitIntoChunks = (size) ->
    return _.chain(@).groupBy((element, index) ->
        Math.floor index / size
    ).toArray().value()

Array::pushArray = (ar) ->
    for el in ar
        @push el
    @

Array::getIndexBy = (predicate) ->
    for el, i in @
        if predicate el
            return i
    return -1

Array::clone = ->
    @slice(0)

Array::cloneWithObjects = ->
    _.map @slice(0), (i) ->
        if typeof i is 'object'
            _.extend {}, i
        else
            i