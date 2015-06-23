Meteor.methods {
    'addEmptyTranslation': (key, route) ->

        translatorService = Crater.Services.Get Services.TRANSLATOR
        translatorService.addEmptyTranslation key, route
}