Meteor.methods {
    'createUserWithEmail': (doc) ->
        try
            userSchema = Crater.Schema.Get Crater.Schema.Account.EmailSignup
            check doc, userSchema

            accountService = Crater.Services.Get Services.ACCOUNT
            return accountService.createUserWithEmail(doc)
        catch e
            if Meteor.settings.debug
                throw e
            return false

    'users.legacyLogin': (email, pwd) ->
        accountService = Crater.Services.Get Services.ACCOUNT
        accountService.processLegacyLogin email, pwd

    'users.verifyPassword': (pwd) ->
        check pwd, String

        accountService = Crater.Services.Get Services.ACCOUNT
        accountService.verifyPassword Meteor.user(), pwd

    'users.linkedinSignupAlertShown': ->
        user = new MeteorUser Meteor.user()
        user.update {
            $set:
                'platform.linkedin_signup_alert_shown': true
        }

    'users.cookiebarShown': ->
        user = new MeteorUser Meteor.user()
        user.update {
            $set:
                'platform.cookiebar_shown': true
        }

    'loginConnectedUser': ->
        connectedUserId = Helpers.Server.Session.Get SESSION_KEY_CONNECTED_USER_ID

        if connectedUserId
            accountService = Crater.Services.Get Services.ACCOUNT
            newToken = accountService.getNewLoginToken(connectedUserId)

            @setUserId connectedUserId
            Helpers.Server.Session.Set SESSION_KEY_CONNECTED_USER_ID, null, false, true
            return {
                userId: connectedUserId
                token: newToken
                expires: (new Date()).addDays(60)
            }

        return false

    'sendNewPasswordLink': (email) ->

        check email, String

        accountService = Crater.Services.Get Services.ACCOUNT
        accountService.sendNewPasswordLink email

    'users.updateAccountSettings': (doc) ->

        check doc, Crater.Schema.Get Crater.Schema.Account.MainSettings

        accountService = Crater.Services.Get Services.ACCOUNT
        accountService.updateAccountSettings Meteor.userId(), doc

    'setNewUserPassword':  (id, token, password) =>

        check id, String
        check token, String
        check password, String

        accountService = Crater.Services.Get Services.ACCOUNT
        accountService.setNewUserPassword id, token, password

    'setUserLanguage': (lang, forcing) ->

        check lang, String
        check forcing, Boolean

        user = new MeteorUser Meteor.user()

        if user.anonymous # sometimes the user is set on the client, but not on the server
            Helpers.Log.Error 'Trying to set the language for an anonymous user'
            return

        # If the user already specified a language, we are not going to override it unless it's a manual override form the UX
        if not forcing and user.lang_forced
            return

        updateObj = {
            lang: lang
        }

        if forcing or not user.lang_forced # we also want to force it as first selection
            updateObj.lang_forced = true

        user.update {
            $set: updateObj
        }

    'loginAsUser': (userId) ->

        check userId, String

        currentUserId = Meteor.userId()
        currentUser = new MeteorUser Meteor.user()

        if not Roles.userIsInRole Meteor.userId(), 'admin'
            throw 'Unauthorized'

        accountService = Crater.Services.Get Services.ACCOUNT
        newToken = accountService.getNewLoginToken(userId)
        getBackToken = accountService.getNewLoginToken(Meteor.userId())

        @setUserId userId

        Helpers.Server.Session.SetSpoofing true

        {
            userId: userId
            token: newToken
            expires: (new Date()).addDays(60)
            getBackToken: getBackToken
            getBackUserId: currentUserId
            getBackUserName: currentUser.first_name
        }

    'user.autoLogin': (userId, token) ->

        check userId, String
        check token, String

        accountService = Crater.Services.Get Services.ACCOUNT
        accountService.autoLogin.call @, userId, token

    'sendEmailVerificationRequest': ->
        try
            accountService = Crater.Services.Get Services.ACCOUNT
            accountService.sendEmailVerificationRequest()
        catch e
            console.error e

    'verifyUserEmail': (token) ->
        accountService = Crater.Services.Get Services.ACCOUNT
        accountService.verifyUserEmail token

    'ensurePostSignupOps': ->
        @unblock()

        for serviceType in Crater.Users.PostSignupServices
            service = Crater.Services.Get serviceType
            service.ensurePostSignupOps Meteor.userId()

    'uploadProfilePicture': (fileInfo) ->
        Helpers.Server.IO.CheckFilePathFromClient fileInfo

        accountService = Crater.Services.Get Services.ACCOUNT
        accountService.uploadNewProfilePicture Meteor.userId(), Meteor.settings.uploadFolder + fileInfo

        user = new MeteorUser Meteor.user()
        return user.getProfilePictureUrl Crater.Users.PictureSizes.HUGE

    'cropProfilePicture': (cropData) ->
        accountService = Crater.Services.Get Services.ACCOUNT
        accountService.updateProfilePictures Meteor.userId(), null, true, cropData

    'updateUserLocationFromGoogle': (place) ->
        accountServices = Crater.Services.Get Services.ACCOUNT
        accountServices.updateUserLocationFromGoogle Meteor.userId(), place

    'user.getTmpAdminToken': ->
        if not Roles.userIsInRole(Meteor.userId(), 'admin')
            throw 'Unauthorized'

        user = new MeteorUser Meteor.user()
        user.getTmpAdminToken()


    'user.delete': (id) ->
        if not Roles.userIsInRole(Meteor.userId(), 'admin') and Meteor.userId() isnt id
            throw 'Unauthorized'

        check id, String

        user = new MeteorUser id
        user.softDelete()

    'user.undelete': (id) ->
        if not Roles.userIsInRole(Meteor.userId(), 'admin') and Meteor.userId() isnt id
            throw 'Unauthorized'

        check id, String

        user = new MeteorUser id
        user.unDelete()

    'users.setGender': (id, gender) ->

        if not Roles.userIsInRole Meteor.userId(), 'admin'
            throw 'Hey! No!'

        user = new MeteorUser id
        user.update {
            $set:
                gender: gender
        }

    'users.setStatus': (id, status) ->

        if not Roles.userIsInRole(Meteor.userId(), 'admin')
            throw 'Bad puppy!'

        check id, String
        check status, String

        user = new MeteorUser id
        user.update {
            $set:
                status: status
        }

    'users.setStatusNoSecurityCheck': (id, status) ->

        check id, String
        check status, String

        user = new MeteorUser id
        user.update {
            $set:
                status: status
        }

    'users.signupTracked': ->
        user = new MeteorUser Meteor.user()
        user.update {
            $set:
                'platform.signup_tracked': true
        }

    'users.exportToIntercom': ->
        if not Roles.userIsInRole Meteor.userId(), 'admin'
            throw 'Bad puppy!'

        accountService = Crater.Services.Get Services.ACCOUNT
        accountService.exportToIntercom()

    'users.setUTMTrackingInfo': (utmInfo) ->
        if Meteor.userId()
            user = new MeteorUser Meteor.user()
            user.update {
                $set:
                    utm_info: utmInfo
            }

    'users.removeEmptyLocations': ->

        users = Meteor.users.find().fetch()

        for user in users
            for jobLocation in user.job_locations || []
                if not (jobLocation?.trim())
                    console.log user.job_locations.length
                    user.job_locations = _.filter(user.job_locations, (jl) -> jl)
                    console.log user.job_locations.length
                    Meteor.users.update user._id, {
                        $set:
                            job_locations: user.job_locations
                    }
                    break

    'users.updateRecent': (all) ->
        if not Roles.userIsInRole Meteor.userId(), 'admin'
            throw 'Bad kitty!'

        accountService = Crater.Services.Get Services.ACCOUNT
        accountService.updateRecent(all)

    'users.ensureAutoLogins': ->
        if not Roles.userIsInRole Meteor.userId(), 'admin'
            throw 'Bad doggy!'

        accountService = Crater.Services.Get Services.ACCOUNT

        users = Meteor.users.find().fetch()

        for user in users
            user = new MeteorUser user
            accountService.getUserAutologinToken(user, 100)

    'users.updateLocationGeocode': ->

        if not Roles.userIsInRole Meteor.userId(), 'admin'
            throw 'Bad kittydoggy'

        accountService = Crater.Services.Get Services.ACCOUNT
        accountService.updateLocationGeocode()

}