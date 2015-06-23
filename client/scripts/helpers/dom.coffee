class @Helpers.Client.DOM

    @OnEnterKey: (source, callback) =>
        source.keypress (e) ->
            if e.which is 13
                callback()