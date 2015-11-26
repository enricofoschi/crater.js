@Services = {
    LOG:
        key: 'log'
        service: -> new Crater.Services.Core.Log()

    EMAIL:
        key: 'email'
        service: -> new Crater.Services.Communications.Email(Meteor.settings.mandrill)

    XING:
        key: 'xing',
        service: -> new Crater.Services.ThirdParties.Xing Meteor.settings.xing?.key, Meteor.settings.xing?.secret

    LINKEDIN:
        key: 'linkedin',
        service: -> new Crater.Services.ThirdParties.LinkedIn()

    AMAZON:
        key: 'amazon'
        service: -> new Crater.Services.ThirdParties.Amazon(
            Meteor.settings.AWS.accessKeyId
            Meteor.settings.AWS.secretAccessKey
            Meteor.settings.AWS.bucketName
            Meteor.settings.AWS.region
        )

    ELASTIC_SEARCH:
        key: 'elastic_search'
        service: -> new Crater.Services.ThirdParties.ElasticSearch()

    KIBANA:
        key: 'kibana'
        service: -> new Crater.Services.ThirdParties.Kibana()

    HIGHRISE:
        key: 'highrise'
        service: -> new Crater.Services.ThirdParties.Highrise Meteor.settings.highrise?.apiToken, Meteor.settings.highrise?.password

    STATE_MACHINE:
        key: 'state_machine'
        service: -> new Crater.Services.Core.StateMachine()
}

@Crater.Services.InitAll()

