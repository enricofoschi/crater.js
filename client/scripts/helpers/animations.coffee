globalContext = @

class @Helpers.Client.Animations

    @AddInAnimation: (source, callback) ->
        source.each ->
            @_uihooks = _.extend @_uihooks || {}, {
                insertElement: (node, next) ->

                    $node = $(node)
                    $node.insertBefore(next)
                    $node.addClass 'animated flipInX'

                    if callback
                        callback()
            }

    @AddOutAnimation: (source, callback) ->
        source.each ->
            @_uihooks = _.extend @_uihooks || {}, {
                removeElement: (node) ->

                    $node = $(node)
                    $node.addClass 'animated flipOutX'

                    Meteor.setTimeout ->
                        $node.remove()
                    , 500

                    if callback
                        callback()
            }