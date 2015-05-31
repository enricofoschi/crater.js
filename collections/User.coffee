class @MeteorUser

    _user = null
    _profile = null

    profile: null

    constructor: (user) ->
        _user = user
        @profile = user.profile

    getEmail: ->

        email = _user?.services?.linkedin?.emailAddress

        if not email
            email = _user?.emails?[0]?.address

        email

