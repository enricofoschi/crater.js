global = @
global.CurrentTemplateLayout = new ReactiveVar()

@Crater.Routing = {
    Controllers: {}
}

Router.configure {
    loadingTemplate: 'loader'
    waitOn: ->
        [
            Meteor.subscribe 'roles'
        ]
}

@Crater.Routing.Controllers.Presentation = {
    controller: Helpers.Router.AddController {
        name: 'presentation'
        layoutTemplate: 'PresentationLayout'
        onAfterAction: ->
            setBodyLayout 'presentation'
    }
}

@Crater.Routing.Controllers.Admin = {
    controller: Helpers.Router.AddController {
        name: 'admin'
        layoutTemplate: 'AdminLayout'
        onBeforeAction: ->
            if not Roles.userIsInRole Meteor.userId(), GlobalSettings.adminRoles
                @render 'admin.login'
            else
                @next()
        onAfterAction: ->
            window.setTimeout =>
                Session.set('refresh', Math.random()) # Used to refresh sidebar menu
                $('#side-menu .active').removeClass('active')
            , 0
    }
}