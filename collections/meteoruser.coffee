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
        if google = getGoogle()
            return google.email
        else
            return _user?.emails?[0]?.address

    getFirstName: =>
        if google = getGoogle()
            return google.given_name
        else
            return @profile.firstName

    getGoogleAccessToken: =>
        if google = getGoogle()
            return google.accessToken
        return ''

    getRefreshToken: =>
        if google = getGoogle()
            return google.refreshToken
        return ''

    update: (attr) =>
        Meteor.users.update _user._id, attr

    @getUser: (userId) =>
        new MeteorUser(Meteor.users.findOne(userId))

    # Third Parties Checker
    getGoogle = =>
        return _user?.services?.google
