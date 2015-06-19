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

        @init user

    init: (user) =>
        @profile = user?.profile
        @services = user?.services
        @_id = user?._id
        @email = @getEmail()
        @anonymous = (user?._id || '').length is 0
        @registered = not @anonymous

    getEmail: =>
        if google = getGoogle()
            return google.email
        else if xing = getXing()
            return xing.active_email
        else if linkedin = getLinkedIn()
            return linkedin.emailAddress
        else
            return _user?.emails?[0]?.address

    getFirstName: =>
        if google = getGoogle()
            return google.given_name
        else
            return @profile.firstName

    update: (attr) =>
        Meteor.users.update _user._id, attr
        @init Meteor.users.findOne _user._id

    attachServices: (services) =>
        setAttr = {}
        setAttr.services = _.extend @services || {}, services
        @update setAttr

    @getUser: (userId) =>
        new MeteorUser(Meteor.users.findOne(userId))

    # Xing
    getXing = =>
        return _user?.services?.xing

    getXingAccessToken: =>
        if xing = getXing()
            return xing.accessToken

    getXingAccessTokenSecret: =>
        if xing = getXing()
            return xing.accessTokenSecret

    # Google
    getGoogle = =>
        return _user?.services?.google

    getGoogleAccessToken: =>
        if google = getGoogle()
            return google.accessToken
        return ''

    getGoogleRefreshToken: =>
        if google = getGoogle()
            return google.refreshToken
        return ''

    # LinkedIn
    getLinkedIn = =>
        return _user?.services?.linkedin

    getLinkedInAccessToken: =>
        if linkedin = getLinkedIn()
            return linkedin.accessToken
        return ''