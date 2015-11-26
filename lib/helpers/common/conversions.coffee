class @Helpers.Conversions

    @ToArray: (obj) ->
        return (element for element in obj when element)

    @ToOptionalSchema: (schema) ->
        ->
            retVal = schema()

            for own key, value of retVal
                retVal[key].optional = true

            retVal

