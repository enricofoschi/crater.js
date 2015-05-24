class @Helpers.Conversions

    @ToArray: (obj) ->
        return (element for element in obj when element)

