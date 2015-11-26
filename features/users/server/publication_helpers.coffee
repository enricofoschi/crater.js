class @Crater.Users.Server.PublicationHelpers

    privateFields = {
        email: true
        emails: true
        platform: true
        notifications: true
        lang: true
        lang_forced: true
        profile: true
        first_name: true
        last_name: true
        full_name: true
        pictures: true
        location: true
        links: true
        files: true
        phone: true
        updatedAt: true
        status: true
        gender: true
        sleeping: true
        need_visa: true
        'migration.id': true
        'services.linkedin.id': true
        'services.xing.id': true
        'services.google.id': true
        createdAt: true
    }

    @AddPrivatePublicationFields: (fields) =>

        for field in fields
            privateFields[field] = true

    publicFields = {
        first_name: true
        last_name: true
        full_name: true
        pictures: true
    }

    anonymousFields = {
        nothing: 1
    }

    publicServiceProviderFields = {
        google: []
        linkedin: []
        xing: []
    }

    privateServiceProviderFields = {}

    @GetPublicationFields: (userId = null) ->

        if (userId and userId is @userId) or Roles.userIsInRole @userId, ['admin']
            privateFields
        else if @userId
            publicFields
        else
            anonymousFields

    @InitFields: =>
        for own key, value of privateServiceProviderFields
            for field in value
                privateFields['services.' + key + '.' + field] = 1

        for own key, value of publicServiceProviderFields
            for field in value
                publicFields['services.' + key + '.' + field] = 1

    @AddPrivateField: (fields) =>
        privateFields = _.extend privateFields, fields

    @InitFields()
