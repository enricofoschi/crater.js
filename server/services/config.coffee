@Services = {
    LOG:
        key: 'log'
        service: -> new Crater.Services.Core.Log()

    ACCOUNT:
        key: 'account'
        service: -> new Crater.Services.Core.Account()

    XING:
        key: 'xing',
        service: -> new Crater.Services.ThirdParties.Xing Meteor.settings.xing?.key, Meteor.settings.xing?.secret

    LINKEDIN:
        key: 'linkedin',
        service: -> new Crater.Services.ThirdParties.LinkedIn()
}

@Crater.Services.InitAll()

