class @Crater.Api.Highrise.People extends @Crater.Api.Highrise.Base

    _baseUrl: Meteor.settings.urls.highrise
    _contentType: 'application/xml'
    _userAgent: 'crater.js'

    PERSON_MAPPING = {
        'first-name': (u) -> u.first_name
        'last-name': (u) -> u.last_name
        'title': (u) -> u.role
        'company-name': (u) -> u.company_name

    }

    DeletePerson: (user, callback) =>

        console.log 'Removing user from highrise: ' + user._id

        @Call 'delete', 'people/' + user.platform.highrise.id, {
        }, (e, r) ->
            if not e
                user.update {
                    $unset:
                        'platform.highrise': null
                }

            callback e, r

    UpdatePerson: (user, callback) =>
        callbackCalled = false # failsafe
        _callback = callback
        callback = (e, r) ->
            _callback e, r if not callbackCalled
            callbackCalled = true

        if not MeteorUser.GetUserType(user).PushToHighrise
            callback(null, null)
            return

        builder = Meteor.npmRequire 'xmlbuilder'
        xml = builder.create 'person'

        for own key, value of PERSON_MAPPING
            val = value(user)
            xml.ele(key).txt(val) if val

        # Contacts
        contactData = xml.ele('contact-data')

        emailEl = contactData.ele('email-addresses').ele('email-address')
        if user.platform?.highrise?.email_id
            emailEl.ele('id', {
                type: 'integer'
            }).txt(user.platform.highrise.email_id)
        emailEl.ele('address').txt(user.email)
        emailEl.ele('location').txt('Work')

        if user.phone
            phoneEl = contactData.ele('phone-numbers').ele('phone-number')
            if user.platform?.highrise?.phone_id
                phoneEl.ele('id', {
                    type: 'integer'
                }).txt(user.platform.highrise.phone_id)
            phoneEl.ele('number').txt(user.phone)
            phoneEl.ele('location').txt('Work')

        # Custom Data
        customData = xml.ele('subject_datas', {
            type: 'array'
        })

        addCustomData = (id, value) ->
            return if not value

            subjectData = customData.ele('subject_data')
            subjectData.ele('value').txt(value)
            subjectData.ele('subject_field_id', {
                type: 'integer'
            }).txt(id)

        addCustomData(1022576, user.status)
        addCustomData(1023926, user.gender)
        addCustomData(1024050, user.getUrl(true))
        addCustomData(1024051, user.getIntercomUrl())
        addCustomData(1031121, user.skype)
        addCustomData(1023925, user.lang)
        addCustomData(1022585, moment(user.createdAt).format(ServerSettings.dateFormat))

        data = customData.end()

        xmlParser = Meteor.npmRequire 'xml2js'

        console.log 'About to push ' + user._id
        if ServerSettings.debug
            callback(null, null)
            return

        if user.platform?.highrise?.id
            console.log 'Updating'
            @Call 'put', 'people/' + user.platform.highrise.id + '.xml?reload=true', {
                content: data
            }, (e, r) ->
                if not e
                    xmlParser.parseString r.content, (e, r) ->
                        callback null, r.person
                else
                    callback e, null
        else if not user.platform?.highrise?.creating # to ensure we don't fire two creates at the same time
            user.update {
                $set:
                    'platform.highrise.creating': true
            }
            try
                console.log 'Creating'
                @Call 'post', 'people.xml', {
                    content: data
                }, (e, r) ->
                    if not e
                        xmlParser.parseString r.content, (e, r) ->
                            user.update {
                                $set:
                                    'platform.highrise.id': r.person.id[0]._
                                    'platform.highrise.email_id': r.person['contact-data']?[0]?['email-addresses']?[0]?['email-address']?[0]?.id?[0]?._
                                    'platform.highrise.phone_id': r.person['contact-data']?[0]?['phone-numbers']?[0]?['phone-number']?[0]?.id?[0]?._
                                $unset:
                                    'platform.highrise.creating': null
                            }
                            callback null, r.person
                    else
                        callback e, null
            catch e
                user.update {
                    $unset:
                        'platform.highrise.creating': null
                }
                callback e, null

        callback()
