fs = Npm.require 'fs'

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

    @SetTemplates: (_head, _foot) ->
        head = _head
        foot = _foot

    @Init: (template, html, helpers) ->

        if not templates[template]
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

    @GetBody: (properties) ->

        @Init properties.template, properties.html, properties.helpers

        html = head.format _.extend properties.data || {}, {
            title: properties.title
        }
        html += SSR.render properties.template, properties.data
        html += foot

        html

    @Send: (options) ->

        html = @GetBody {
            template:   options.template
            html:       options.html
            title:      options.subject
            data:       _.extend options.data || {}, {
                imageUrl: Meteor.absoluteUrl() + 'img/'
            }
            helpers:    options.helpers
        }

        Meteor.Mailgun.send {
            from:       options.from || Meteor.settings.mailgun.from
            to:         options.to
            subject:    options.subject
            html:       html
        }