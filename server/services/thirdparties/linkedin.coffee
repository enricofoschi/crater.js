class @Crater.Services.ThirdParties.LinkedIn extends @Crater.Services.ThirdParties.Base

    _profileApi = null
    _token = null

    constructor: () ->

        @_profileApi = new Crater.Api.LinkedIn.Profile()

    getProfileInfo: (user) ->
        Meteor.wrapAsync(@_profileApi.getProfileInfo) user



