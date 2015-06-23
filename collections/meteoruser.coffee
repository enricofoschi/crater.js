class @MeteorUser


    _user: null
    _id: null

    email: null
    anonymous: true
    registered: false
    profile: null
    services: null

    constructor: (user) ->
        if typeof(user) is 'string'
            user = Meteor.users.findOne user

        @_user = user

        @init user

    init: (user) =>
        @profile = user?.profile
        @services = user?.services
        @_id = user?._id
        @id =
        @email = @getEmail()
        @anonymous = (user?._id || '').length is 0
        @registered = not @anonymous

    getEmail: =>
        if facebook = @getFacebook()
            return facebook.email
        if google = @getGoogle()
            return google.email
        else if xing = @getXing()
            return xing.active_email
        else if linkedin = @getLinkedIn()
            return linkedin.emailAddress
        else
            return @_user?.emails?[0]?.address

    getFullName: =>
        if facebook = @getFacebook()
            return facebook.name
        if linkedin = @getLinkedIn()
            return linkedin.profile.formattedName
        return 'somebody'

    getFirstName: =>
        if facebook = @getFacebook()
            return facebook.first_name
        if linkedin = @getLinkedIn()
            return linkedin.firstName
        if google = @getGoogle()
            return google.given_name
        else
            return @profile?.firstName || 'somebody'

    getProfilePicture: =>
        if facebook = @getFacebook()
            return 'http://graph.facebook.com/' + facebook.id + '/picture?width=250'
        if linkedin = @getLinkedIn()
            if linkedin.profile.pictureUrls._total > 0
                return linkedin.profile.pictureUrls.values[0]

    isAdminByEmail: =>
        return @getEmail() in Meteor.settings.adminEmails

    update: (attr) =>
        Meteor.users.update @_user._id, attr
        @init Meteor.users.findOne @_user._id

    attachServices: (services) =>
        setAttr = {}
        setAttr.services = _.extend @services || {}, services
        @update setAttr

    @getUser: (userId) =>
        new MeteorUser(Meteor.users.findOne(userId))

    isAdmin: =>
        Roles.userIsInRole Meteor.userId(), GlobalSettings.adminRoles

    # Xing
    getXing: =>
        return @_user?.services?.xing

    getXingAccessToken: =>
        if xing = @getXing()
            return xing.accessToken

    getXingAccessTokenSecret: =>
        if xing = @getXing()
            return xing.accessTokenSecret

    # Google
    getGoogle: =>
        return @_user?.services?.google

    getGoogleAccessToken: =>
        if google = @getGoogle()
            return google.accessToken
        return ''

    getGoogleRefreshToken: =>
        if google = @getGoogle()
            return google.refreshToken
        return ''

    # Facebook
    getFacebook: =>
        return @_user?.services?.facebook

    # LinkedIn
    getLinkedIn: =>
        return @_user?.services?.linkedin

    getLinkedInAccessToken: =>
        if linkedin = @getLinkedIn()
            return linkedin.accessToken
        return ''