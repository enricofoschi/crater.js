global = @

class @Helpers.Client.TemplatesHelper

    templateInits = {}

    @GetContainer: (instance) =>
        $(instance.firstNode).parent()

    @Handle: (name, onInit, rendered) =>

        templateInits[name] = onInit

        if not Template[name]
            Helpers.Log.Error 'Template ' + name + ' not found'
            return

        _rendered = Template[name].rendered
        Template[name].rendered = ->

            if _rendered
                _rendered.apply @, arguments

            if rendered
                rendered.apply @, arguments

            Template[name].uniqueInstance = @
            Template[name].uniqueContainer = TemplatesHelper.GetContainer @


        Template[name].created = ->
            if templateInits[name]
                Helpers.Log.Info 'Initialized template: ' + name
                TemplatesHelper.InitTemplate name
                Template[name].created.apply @, arguments
                Object.deleteProperty templateInits, name
            if @data?.page?.title
                Helpers.Log.Info 'Setting Meta'
                Helpers.Client.SEO.SetTitle @data.page.title
                Helpers.Client.SEO.SetDescription(@data.page.description) if @data.page.description
                Helpers.Client.SEO.SetImage(@data.page.image) if @data.page.image

        Template[name].onDestroyed(->
            try
                Helpers.Client.Form.Destroy(@)
            catch e
                throw e if ServerSettings.debug
        )

    @InitTemplate: (name = '') =>

        template = Template[name]

        templateInits[name] template

        template.created = ->

            Helpers.Log.Info 'Running onCreate for ' + name

            Meteor.setTimeout ->
                routeProperties = Helpers.Router.GetCurrentRouteProperties()
                Helpers.Analytics.TrackPage routeProperties?.name || location.pathname
            , 0

            Helpers.Client.Loader.Reset()

            if template.onCustomCreated
                template.onCustomCreated.apply @, arguments

        template.helpers {
            currentUser: ->
                return new MeteorUser(Meteor.user())
            currentInstance: ->
                return Template.instance()
            lang: ->
                return Helpers.Client.SessionHelper.Get(@LANGUAGE_KEY)
        }

        template.getReactiveProperty = (data, name) ->
            if not data[name]
                data[name] = new ReactiveVar()

            data[name]


        template

    @Init: ->

        Template.registerHelper 't', (msg) ->
            translate msg

        Template.registerHelper 'title', ->
            Helpers.Router.CurrentTitle

        Template.registerHelper 'imgPath', ->
            ServerSettings.urls.imgs

        Template.registerHelper 's', ->
            Helpers.Client.Static.IncludeContent.apply @, arguments

        Template.registerHelper 'log', ->
            Helpers.Log.Info @
            Helpers.Log.Info arguments

        Template.registerHelper 'afFieldValue', ->
            AutoForm.getFieldValue(@formId, @name) || ''

        $(document).on 'click', '.track-me', ->
            $target = $ @
            if trackAction = $target?.attr('data-track')
                Helpers.Analytics.Track trackAction
            return true

