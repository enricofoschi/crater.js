class @Crater.Services.ThirdParties.Highrise extends @Crater.Services.ThirdParties.Base

    _peopleAPI: null

    constructor: (username, password) ->
        @_peopleAPI = new Crater.Api.Highrise.People {
            username: username
            password: password
        }

    updateUser: (user, callback) =>
        result = Meteor.wrapAsync(@_peopleAPI.UpdatePerson) user

    deleteUser: (user, callback) =>
        result = Meteor.wrapAsync(@_peopleAPI.DeletePerson) user