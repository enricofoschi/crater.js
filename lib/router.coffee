global = @
global.CurrentTemplateLayout = new ReactiveVar()

Router.configure {
    loadingTemplate: 'loader'
    waitOn: ->
        Meteor.subscribe 'roles'
        Meteor.subscribe 'translations', Router.current().route.getName()
}

@BaseController = RouteController.extend {
    onBeforeAction: ->
        console.log 'Hey'
}