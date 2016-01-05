class @Crater.Api.Mandrill.Email extends Crater.Api.Mandrill.Base

    username: null
    password: null

    _baseUrl: 'https://mandrillapp.com/api/1.0/messages/send-template.json'

    constructor: (@username, @password) ->
        super {}

    SendTemplate: (slug, message, to) =>

        isCompanyEmail = (to || '').toLowerCase().indexOf(ServerSettings.companyEmailDomain) > -1

        # Debug
        originalTo = to
        if Meteor.settings.debug
            to = Meteor.settings.email.catchAll
            Object.deleteProperty message, 'to'

        # Language
        lang = message.lang || Helpers.Translation.GetUserLanguage()
        delete message.lang

        # Slug (with or with    out translation)
        slug = (Meteor.settings.mandrill.templatePrefix || '') + slug + (if message.untranslated then '' else '-' + lang)
        delete message.untranslated

        tos = [
            {
                email: to
            }
        ]

        if Meteor.settings.email.alwaysBcc and not isCompanyEmail
            tos.push {
                email: Meteor.settings.email.alwaysBcc
                type: 'bcc'
            }

        message = _.extend {
            track_opens: true
            auto_text: true
            inline_css: true
            preserve_recipients: false
            merge_language: 'handlebars'
            to: tos
        }, message

        data = {
            key: @password
            template_name: slug
            template_content: []
            message: message
            headers: [{
                'Content-Type': 'application/json'
            }]
        }

        try
            if not Meteor.settings.disableEmail
                HTTP.post @_baseUrl, {
                    data: data
                }
            else
                console.log 'Would have sent an email (template: ' + slug + ' - to: ' + to + ') but email sending is disabled'

            Crater.Collections.Email.create {
                template: slug
                data: data
                to: originalTo
            }
        catch e
            @_logService.Error e
            throw e
