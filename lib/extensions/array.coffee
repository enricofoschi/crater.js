Array::any = (f) ->
    (return true if f x) for x in @
    return false

Array::remove = (f) ->
    (x for x in @ when not f x)

Array::present = ->
    @.length > 0

Array::toMatrix = (max) ->
    matrix = []

    max = if max > 0 then max else 2

    index = max

    while index < @.length + max
        matrix.push (x for x, i in @ when i >= index - max and i < index)
        index += max

    matrix

Array::fromObj = (obj) ->

    for own key,value of obj
        @push {
            key: key
            value: value
        }