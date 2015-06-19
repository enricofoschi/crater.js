Router.configure {
    loadingTemplate: 'loader'
    waitOn: ->
        Meteor.subscribe 'roles'
        Meteor.subscribe 'translations', Router.current().route.getName()
}