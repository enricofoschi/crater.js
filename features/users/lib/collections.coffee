globalContext = @

class @MeteorUser

    @EXPLICIT_UPDATE: true
    @RoleMapping: {}

    _user: null
    anonymous: true
    registered: false

    lang: null
    lang_forced: null

    INTERCOM_ATTRIBUTE_MAPPINGS = [
        'name'
        'email'
        'signed_up_at'
        'last_request_at'
    ]

    # Roles
    hasRole: (role) =>
        role in (@roles || [])

    getMainRole: =>
        roles = @roles || []

        for own role, mapping of @constructor.RoleMapping
            if role in roles
                return role

        return null

    @AddRoleMapping: (role, mapping) =>
        @RoleMapping[role] = mapping

    @GetUserType: (user) =>
        roles = user.roles || []

        for own role, mapping of @RoleMapping
            if role in roles
                return mapping

        return MeteorUser

    @GetDefinedUser: (user) =>

        type = @GetUserType(user)

        if type
            new type user
        else
            new globalContext.MeteorUser user

    # Properties mapping with 3rd parties providers
    Properties = {
        FIRST_NAME:
            facebook: (facebook) -> facebook.first_name
            linkedin: (linkedin) -> linkedin.profile.firstName
            google: (google) -> google.given_name
            xing: (xing) -> xing.first_name
            twitter: (twitter) -> twitter.screenName
            default: (user) -> user.profile?.firstName
        LAST_NAME:
            facebook: (facebook) -> facebook.last_name
            linkedin: (linkedin) -> linkedin.profile.lastName
            xing: (xing) -> xing.last_name
            google: (google) -> google.given_name
            default: (user) -> user.profile?.lastName
            none: -> ''
        FULL_NAME:
            facebook: (facebook) -> facebook.name
            linkedin: (linkedin) -> linkedin.profile.formattedName
            default: (user) -> if user.profile then user.profile?.firstName + ' ' + user.profile?.lastName else null
            xing: (xing) -> xing.display_name
            google: (google) -> google.given_name
            twitter: (twitter) -> twitter.screenName
            none: -> ''
        EMAIL:
            facebook: (facebook) -> facebook.email
            linkedin: (linkedin) -> linkedin.emailAddress
            google: (google) -> google.email
            xing: (xing) -> xing.active_email
            default: (user) -> user._user?.emails?[0]?.address
            none: -> ''
        PROFILE_PICTURE_ORIGINAL:
            facebook: (facebook) -> 'http://graph.facebook.com/' + facebook.id + '/picture?width=9999'
            linkedin: (linkedin) -> linkedin.profile.pictureUrls?.values?[0]
            xing: (xing) -> xing.photo_urls.size_original
            twitter: (twitter) -> twitter.profile_image_url
        THIRD_PARTY_URL:
            linkedin: (linkedin) -> linkedin.publicProfileUrl
            twitter: (twitter) -> 'https://twitter.com/' + twitter.screenName
            facebook: (facebook) -> 'http://facebook.com/' + facebook.id
    }

    providers = [
        'google'
        'facebook'
        'linkedin'
        'xing'
        'twitter'
    ]

    constructor: (user) ->
        if typeof(user) is 'string'
            user = Meteor.users.findOne user

        @init user

    init: (user) =>
        user ||= {}

        Object.extendWith @, user

        @_user = user
        @id = @_id
        @anonymous = (user?._id || '').length is 0
        @registered = not @anonymous

# do NOT call this function after signup
    initCoreProperties: =>
        retVal = {}
        retVal.first_name = @getFirstName()
        retVal.last_name = @getLastName()
        retVal.full_name = @getFullName()
        retVal.email = @getEmail()
        retVal.platform = {}
        retVal.status = Crater.Users.Status.INACTIVE
        retVal.url = @getThirdPartyUrl()
        retVal.signup_type = @getSignupType()

        if @profile?.migrated_from
            retVal.migration = {
                migrated: new Date()
                id: @profile.migrated_from
            }

        retVal

    getUrl: (absolute) ->
        return '/' + @_id

    getIntercomUrl: =>
        ServerSettings.urls.intercom + 'users/' + @platform?.intercom_id + '/all-conversations'

    getHighriseUrl: =>
        ServerSettings.urls.highrise + 'people/' + @platform?.highrise?.id

    @getProviders: =>
        providers

    getProperty: (property) =>
        ret = null

        if property.default
            ret = property.default @

        if @services
            for provider in providers when property[provider]
                if @services[provider]

                    ret = property[provider] @services[provider]
                    break

        if not ret and property.none
            ret = property.none()

        return ret

    getEmail: =>
        (@getProperty(Properties.EMAIL) || '').trim().toLowerCase()

    getFirstName: =>
        @getProperty Properties.FIRST_NAME

    getLastName: =>
        @getProperty Properties.LAST_NAME

    getFullName: =>
        @getProperty Properties.FULL_NAME

    getName: =>
        @full_name || @first_name || translate('user.no_name')

    getProfilePictureOriginal: =>
        @getProperty Properties.PROFILE_PICTURE_ORIGINAL

    getThirdPartyUrl: =>
        @getProperty Properties.THIRD_PARTY_URL

    getServices: =>
        retVal = []

        for own key, value of (@services || {}) when key not in ['resume']
            retVal.push(translate('commons.services.' + key))

        retVal.join ', '

    isAdminByEmail: =>
        return @getEmail() in Meteor.settings.adminEmails

    getDerivedFullName: (firstName, lastName) =>
        (firstName || @first_name || '') + ' ' + (lastName || @last_name || '')

    update: (updateObj) =>
        updateObj.$set ||= {}
        updateObj.$set.updatedAt = new Date()

        if updateObj.$set.first_name or updateObj.$set.last_name
            updateObj.$set.full_name = @getDerivedFullName(updateObj.$set.first_name, updateObj.$set.last_name)

        Meteor.users.update @_id, updateObj
        @init Meteor.users.findOne @_user._id

    addToSet: (lists) ->
        updateObj = lists

        Meteor.users.update @_id, {
            $set:
                updatedAt: new Date()
            $addToSet: updateObj
        }

    removeFromSet: (lists) ->
        updateObj = lists

        Meteor.users.update @_id, {
            $set:
                updatedAt: new Date()
            $pull: updateObj
        }

    attachServices: (services) =>
        if not services
            return

        setAttr = {}
        setAttr.services = _.extend @services || {}, services
        @update {
            $set: setAttr
        }

    @getUser: (userId) =>
        new MeteorUser(Meteor.users.findOne(userId))

    isAdmin: =>
        Roles.userIsInRole Meteor.userId(), 'admin'

# Xing
    getXingAccessToken: =>
        @services.xing?.accessToken

    getXingAccessTokenSecret: =>
        @services.xing?.accessTokenSecret

# Google
    getGoogleAccessToken: =>
        @services.google?.accessToken

    getGoogleRefreshToken: =>
        @services.google?.refreshToken

# LinkedIn
    getLinkedInAccessToken: =>
        @services.linkedin?.accessToken

# FTUF
    isFTUFCompleted: =>
        @platform?.ftuf_completed

    setFTUFCompleted: =>
        @update {
            $set:
                'platform.ftuf_completed': true
        }

# Main Fields
    ensureMain: =>
        if not @security_token or not @all_fields
            @update {
                $set:
                    security_token: Helpers.Token.GetGuid()
                    all_fields: 1 # required by subscriptions
            }

# Profile Picture
    getProfilePicturesBaseFolder: =>
        'profile-pictures/' + @_id + '/'

    getProfilePictureOrDefault: (size) =>
        pictureUrl = @getProfilePictureUrl size

        if pictureUrl
            return '<i style="background-image: url(\'' + pictureUrl + '\')" class="profile-picture img"></i>'
        else
            return '<i class="fa fa-user icon"></i>'

    getProfilePictureUrl: (size, useAnonymousPicture = false) =>
        key = @getProfilePictureKey size
        if @pictures and @pictures[key]
            return Helpers.Amazon.GetBucketUrl @pictures[key]
        else
            if useAnonymousPicture
                return ServerSettings.urls.imgs + 'anonymous/anonymous_' + size + '.png'
            else
                return null

    getProfilePictureKey: (size) =>
        'picture_' + size

    updateProfilePictures: (pictures) =>
        @update {
            $set:
                pictures: pictures
        }

# Services
    getSignupType: =>
        if @services?.linkedin?.id
            'linkedin'
        if @services?.xing?.id
            'xing'
        if @services?.google?.id
            'google'
        if @services?.facebook?.id
            'facebook'
        else
            'email'

    profileUrlName: =>
        return null if not @url

        return translate('user.profile.' + @signup_type)

# Email Verified
    isVerified: =>
        not @emails?.length or @emails[0]?.verified

# Tracking
    getTrackingTraits: =>
        traits = {
            name: @full_name,
            firstName: @first_name
            lastName: @last_name
            status: @status
            email: if ServerSettings.debug then ServerSettings.analyticsTestEmail else @email
            last_request_at: @last_visit || @createdAt
        }

        if Meteor.isServer
            if not @platform?.tracked_on_intercom and @lang
                traits.url = @getUrl true
                traits.signed_up_at = @createdAt
                traits.lang = @lang

        role = null

        role = @getMainRole()
        traits.role = role if role
        traits.gender = @gender if @gender
        traits.phone = @phone if @phone
        traits.skype = @skype if @skype
        traits.companyRole = @role if @role
        traits.verified = @isVerified()
        traits.deleted = true if @deleted
        traits

    getTrackingForIntercom: (all) =>
        traits = @getTrackingTraits()

        userData = {
            user_id: @_id
        }

        if @company_id
            userData.companies = [
                {
                    company_id: @company_id
                    name: @company_name
                }
            ]

        userData.custom_attributes = {}

        for own key, value of traits
            if key in INTERCOM_ATTRIBUTE_MAPPINGS
                userData[key] = traits[key]
            else
                userData.custom_attributes[key] = traits[key]

        userData

# Current user singleton
    @currentUser: new @ null
    @userChangesSubscribed: false

    @GetCurrentUser: ->
        if Meteor.isClient
            @_subscribeToUserChanges()

            if not @userChangesSubscribed or (@currentUser._id isnt Meteor.userId() and Meteor.userId()) or not @currentUser.all_fields
                @userChangesSubscribed = true
                @_cacheUser()

        else if Meteor.user?
            @currentUser = new @ Meteor.user()

        return @currentUser

    @_subscribeToUserChanges: =>
        Meteor.user()

    @_cacheUser: (newUser) ->
        @currentUser = new @ (newUser || Meteor.user())

    @Refresh: =>
        @_cacheUser()

    @InitCurrentUserTracker: ->
        if Meteor.isClient

# Caching user for the first time (otherwise it is being cached with the type from MeteorUser regardless)
            @_cacheUser()

            Tracker.autorun =>
                newUser = Meteor.user()

                # we want to set only the user with ALL fields
                if newUser?.all_fields or (@currentUser._id and not Meteor.userId())
                    @_cacheUser newUser

    @InitCurrentUserTracker()

if Meteor.isServer

    Meteor.users.allow {
        insert: (userId, doc) ->
            Roles.userIsInRole userId, ['admin']
        update: (userId, doc) ->
            Roles.userIsInRole userId, ['admin']
        remove: (userId, doc) ->
            Roles.userIsInRole userId, ['admin']
    }

    TRACKING_UPDATE_DRIVERS = [
        'first_name'
        'last_name'
        'full_name'
        'roles'
        'status'
        'gender'
        'phone'
        'skype'
        'email'
        'deleted'
        'services'
        'lang'
    ]

    TRACKING_UPDATE_DRIVERS_HIGHRISE = [
        'company_name'
        'first_name'
        'last_name'
        'full_name'
        'roles'
        'status'
        'gender'
        'phone'
        'skype'
        'email'
        'deleted'
        'services'
        'lang'
    ]

    class @MeteorUser extends MeteorUser

        getESObject: =>

            model = MeteorUser.GetUserType @

            if model?.ESModel
                new model.ESModel @
            else
                null

        getNotificationsUnsubscribeToken: =>
            notificationsGuid = @notifications?.unsubscribe_token

            if not @notifications?.unsubscribe_token

                notificationsGuid = Helpers.Token.GetGuid()

                @update {
                    $set:
                        'notifications.unsubscribe_token': notificationsGuid
                }

            notificationsGuid

        @RecordLastSession: =>
            user = MeteorUser.GetCurrentUser()

            if not user.anonymous
                user.update {
                    $set:
                        last_visit: new Date()
                }

        softDelete: =>
            if Meteor.userId() isnt @_id and not Roles.userIsInRole(Meteor.userId(), 'admin')
                throw 'Unauthorized'

            adminMessage = @full_name + ' (id: ' + @_id + ', email: ' + @email + ', phone: ' + @phone + ') deleted their profile.'

            @_softDeleteNoSecurityCheck()

            Crater.Services.Get(Services.EMAIL).messageAdmin('A user deleted their profile', adminMessage)

        _softDeleteNoSecurityCheck: =>

            emailSuffix = '___' + (new Date()).getTime()

            for email in (@emails || [])
                email.address += emailSuffix

            @update {
                $set:
                    emails: @emails
                    deleted: true
                    email: @email + emailSuffix
                    resume: null
                    services: null
                    services_bak: @services
                    status: Crater.Users.Status.DELETED
            }

        unDelete: =>
            if not Roles.userIsInRole(Meteor.userId(), 'admin')
                throw 'Unauthorized'

            @update {
                $set:
                    services: @services_bak
            }

            @update {
                $unset:
                    deleted: null
                    resume: null
                    services_bak: null
            }

        getTmpAdminToken: =>
            if 'admin' not in @roles
                throw 'Cant'

            newToken = Helpers.Token.GetGuid()

            @update {
                $set:
                    admin_tmp_token: newToken
            }

            newToken

# Getting the token and resetting it for security purposes
        isTmpAdminToken: (token) =>
            r = @admin_tmp_token is token and token.length > 5

            @update {
                $unset:
                    admin_tmp_token: null
            }

            r

        updateIntercomId: =>
            return if Meteor.settings.intercom.disable

            if not @platform?.intercom_id
                intercomClient = Helpers.Analytics.GetIntercomClient()
                result = Meteor.wrapAsync((callback) =>
                    intercomClient.users.listBy({
                            user_id: @_id
                        }, (response) =>
                        callback(null, response)
                    )
                )()
                if result.body?.id
                    @update {
                        $set:
                            'platform.intercom_id': result.body.id
                    }

        updateHighrise: =>
            try
                start = new Date()
                highriseService = Crater.Services.Get Services.HIGHRISE
                highriseService.updateUser @
                console.log 'Highrise upsert', (new Date() - start) / 1000
            catch e
                console.error e
                if ServerSettings.debug
                    throw e

        deleteHighrise: =>
            return if Meteor.settings.debug
            try
                start = new Date()
                highriseService = Crater.Services.Get Services.HIGHRISE
                highriseService.deleteUser @
                console.log 'Highrise delete', (new Date() - start) / 1000
            catch e
                console.error e
                if ServerSettings.debug
                    throw e

        getAutologinSuffix: (duration = 10) =>
            accountService = Crater.Services.Get Services.ACCOUNT
            accountService.getUserAutologinTokenSuffix(@, duration)

    # Data Sanitization
    Crater.startup ->

        users = Meteor.users.find().fetch()

        for user in users
            user = new MeteorUser user

            fullName = user.getDerivedFullName()

            if user.full_name isnt fullName
                console.log 'Sanitizing ' + fullName + ' for ' + user.full_name
                user.update {
                    $set:
                        full_name: fullName
                }

if Meteor.isClient
    # Translations eventually needed
    Meteor.startup ->
        Helpers.Translation.OnCommonTranslationsLoaded ->
            for service in MeteorUser.getProviders()
                translate('commons.services.' + service)

if Meteor.isServer

    users = Meteor.users.find({
        email: /[A-Z]/
    }).fetch()

    users.forEach((user) ->

        console.log('Sanitizing email for', user.full_name, user.email)

        Meteor.users.update(user._id, {
            $set:
                email: user.email?.toLowerCase() || ''
        })
    )
