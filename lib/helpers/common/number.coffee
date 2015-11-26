class @Helpers.Number

    @AddTrailingZeros: (number, minLength) =>
        str = (number || 0).toString()
        length = str.length

        if length < minLength
            zeros = ('0' for zero in [0...(length-minLength)]).join('')
            str = zeros + str

        str
