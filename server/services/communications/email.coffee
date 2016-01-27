class @Crater.Services.Communications.Email extends @Crater.Services.Communications.Base

    mandrillApi: null

    constructor: (mandrillConfig) ->
        @mandrillApi = new Crater.Api.Mandrill.Email(null, mandrillConfig.apiKey)

    # Refactor to use proper casing
    sendWithMandrill: (slug, message, to) =>

        if message.toUser
            message.lang = Meteor.settings.email.forceLang || message.toUser.lang

            message.global_merge_vars ||= []
            message.global_merge_vars.push {
                name: 'isMale'
                content: message.toUser.gender is 'M'
            }
            message.global_merge_vars.push {
                name: 'isFemale'
                content: message.toUser.gender is 'F'
            }

            hasKey = (key) ->
                _.find message.global_merge_vars, (m) -> m.name is key

            if not hasKey 'lastName'
                message.global_merge_vars.push {
                    name: 'lastName'
                    content: message.toUser.last_name
                }
            if not hasKey 'firstName'
                message.global_merge_vars.push {
                    name: 'firstName'
                    content: message.toUser.first_name
                }

        delete message.toUser

        @mandrillApi.SendTemplate(slug, message, to)

    messageAdmin: (subject, content) =>
        logServices = Crater.Services.Get Services.LOG

        try
            @sendWithMandrill('admin-simple-message', {
                subject: subject
                untranslated: true
                global_merge_vars: [
                    {
                        name: 'message'
                        content: content
                    }
                ]
            }, Meteor.settings.email.admin)
        catch e
            logServices.Error(e)
            throw e if Meteor.settings.debug