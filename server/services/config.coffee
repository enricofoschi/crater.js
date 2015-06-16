@Services = {
    LOG:
        key: 'log'
        service: -> new Crater.Services.Core.Log()

    XING:
        key: 'xing',
        service: -> new Crater.Services.ThirdParties.Xing Meteor.settings.xing.key, Meteor.settings.xing.secret

    LINKEDIN:
        key: 'linkedin',
        service: -> new Crater.Services.ThirdParties.LinkedIn()

}

Meteor.startup ->

    for own key, value of Services
        @Crater.Services.Init value