class @Helpers.Server.Email

    templates = {}

    head = null
    foot = null

    styleMain = "font-family: 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif; margin: 0; padding: 0;box-sizing: border-box;"
    styleSize14 = 'font-size: 14px; '
    styleMain14 = styleMain + styleSize14
    styleTable = styleMain14
    styleTd = styleTable + 'padding: 0 0 20px;'
    styleParagraph = styleMain14 + ' margin: 0 0 10px; padding: 0;'


    @Init: (template, helpers) ->

        if not templates[template]
            html = Assets.getText "templates/email/#{template}.html"
            SSR.compileTemplate template, html

            helpers = _.extend {
                styleMain: styleMain,
                styleMain14: styleMain14,
                styleParagraph: styleParagraph
                styleTable: styleTable
                styleTd: styleTd
            }, helpers ||= {}

            Template[template].helpers helpers

            templates[template] = true

        if not head or not foot
            head = Assets.getText 'templates/email/base/head.html'
            foot = Assets.getText 'templates/email/base/foot.html'

    @GetBody: (properties) ->

        @Init properties.template, properties.helpers

        html = head.format {
            title: properties.title
        }
        html += SSR.render properties.template, properties.data
        html += foot

        html

    @Send: (options) ->

        html = @GetBody {
            template:   options.template
            title:      options.subject
            data:       options.data
            helpers:    options.helpers
        }

        sender = new Mailgun {
            apiKey: Meteor.settings.mailgun.apiKey
            domain: Meteor.settings.mailgun.domain
        }

        sender.send {
            from:       Meteor.settings.mailgun.from
            to:         options.to
            subject:    options.subject
            html:       html
        }