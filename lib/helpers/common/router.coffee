ironRouter = Router
ironRouteController = RouteController

class @Helpers.Router

    currentLayout = null
    currentRouteName = null

    routes = []

    setBodyLayout = (layout) ->
        body = $ document.body

        if body.attr 'data-layout-class'
            body.removeClass body.attr 'data-layout-class'

        classes = 'layout-' + layout

        # adding current mapping
        classes += ' ' + (Router.current?()?.route?.getName() || '')

        # adding current roles
        for role in Roles.getRolesForUser Meteor.userId()
            classes += ' ' + 'role-' + role

        body.addClass classes
        body.attr 'data-layout-class', classes

    @Path: (route, params, options) =>
        route.path params, options

    @AddRoute: (route) =>
        routes.push route

    @SetRoute: (route) =>

        path = '/:lang?/' + route.path
        title = route.title
        delete route.title
        delete route.path

        route.controller = route.controller.controller

        action = route.action
        originalOnBeforeAction = route.onBeforeAction

        route.onBeforeAction = ->

            if originalOnBeforeAction
                return originalOnBeforeAction()

            @next()

        route.action = ->
            if @ready()

                if title
                    Helpers.Client.SEO.SetTitle title()
                else
                    Helpers.Client.SEO.SetTitle GlobalSettings.companyName


                if currentLayout isnt route.controller.layout
                    @layout route.controller.layout

                Helpers.Log.Info 'Action rendered'

                return action.apply @
            else
                @layout 'loader'
                @render 'loading'

        ironRouter.route path, route

    @GetCurrentRouteName: =>
        currentRouteName

    @AddController: (controller) =>

        originalOnAfterAction = controller.onAfterAction
        originalOnBeforeAction = controller.onBeforeAction
        layout = controller.layoutTemplate
        delete controller.layoutTemplate

        if Meteor.isClient
            originalWaitOn = controller.waitOn

            controller.waitOn = ->
                currentRouteName = @route.getName()

                retVal = []

                if originalWaitOn
                    retVal = originalWaitOn()

                retVal.push ReactivePromise.when("craterStarted", Crater._startedDeferred.promise());
                retVal.push Meteor.subscribe('translations', Helpers.Translation.GetUserLanguage(), currentRouteName)

                retVal

            controller.onAfterAction = =>
                setBodyLayout controller.name

                if originalOnAfterAction
                    originalOnAfterAction()

        ret = ironRouteController.extend controller

        ret.layout = layout
        ret

    @Init: =>
        for route in routes
            @SetRoute route