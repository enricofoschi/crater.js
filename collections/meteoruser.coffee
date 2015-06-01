class @MeteorUser


    _user = null
    _profile = null

    email: null
    anonymous: true
    profile: null

    constructor: (user) ->
        _user = user
        @profile = user?.profile
        @email = @getEmail()
        @anonymous = (user?._id || '').length

    getEmail: ->

        email = _user?.services?.linkedin?.emailAddress

        if not email
            email = _user?.emails?[0]?.address

        email

