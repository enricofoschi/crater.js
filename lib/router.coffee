global = @
global.CurrentTemplateLayout = new ReactiveVar()

Router.configure {
    loadingTemplate: 'loader'
    waitOn: ->
        [
            Meteor.subscribe 'roles'
        ]
}