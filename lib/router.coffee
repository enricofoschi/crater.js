Router.configure {
    loadingTemplate: 'loader'
    waitOn: ->
        Meteor.subscribe 'roles'
}