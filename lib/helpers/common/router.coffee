globalContext = @

class @Helpers.Router

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

    @AddRoute: (route) =>

        path = '/' + route.path
        delete route.path

        action = route.action

        route.action = ->
            if @ready()
                @layout route.controller.layout
                action.apply @
            else
                @layout 'loader'
                @render 'loading'

        globalContext.Router.route path, route

    @AddController: (controller) =>

        originalOnAfterAction = controller.onAfterAction
        layout = controller.layoutTemplate
        delete controller.layoutTemplate

        if Meteor.isClient
            originalWaitOn = controller.waitOn

            controller.waitOn = =>
                retVal = []

                if originalWaitOn
                    retVal = originalWaitOn()

                retVal.push ReactivePromise.when("craterStarted", Crater._startedDeferred.promise());
                retVal.push Meteor.subscribe('translations', globalContext.Router.current().route.getName())

                retVal

        ret = globalContext.RouteController.extend _.extend(controller, {
            onAfterAction: =>

                setBodyLayout controller.name

                if originalOnAfterAction
                    originalOnAfterAction()
        })

        ret.layout = layout
        ret