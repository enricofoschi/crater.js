Meteor.methods {
    'createUserWithEmail': (doc) ->
        accountService = Crater.Services.Get Services.ACCOUNT
        accountService.createUserWithEmail(doc)
}