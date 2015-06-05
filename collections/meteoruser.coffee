class @MeteorUser


    _user = null
    _profile = null
    _id = null

    email: null
    anonymous: true
    registered: false
    profile: null
    services: null

    constructor: (user) ->

        if typeof(user) is 'string'
            user = Meteor.users.findOne user

        _user = user

        @profile = user?.profile
        @services = user?.services
        @_id = user?._id
        @email = @getEmail()
        @anonymous = (user?._id || '').length is 0
        @registered = not @anonymous

    getEmail: =>

        email = _user?.services?.linkedin?.emailAddress

        if not email
            email = _user?.services?.google?.email

        if not email
            email = _user?.emails?[0]?.address

        email

    getGoogleAccessToken: =>
        @services?.google?.accessToken

    getRefreshToken: =>
        @services?.google?.refreshToken

    update: (attr) =>
        Meteor.users.update _user._id, attr
