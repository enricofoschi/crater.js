Meteor.methods {
    'logError': ->
        console.log 'Client error:'
        console.log arguments

        Crater.Collections.Error.create {
            data: arguments
        }
}

@AVOID_THROTTLING_FOR.push 'logError'