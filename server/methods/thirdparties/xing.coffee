Meteor.methods {
    'xing.getLoginUrl': ->
        xingService = Crater.Services.Get Services.XING
        xingService.getToken(@connection)
}