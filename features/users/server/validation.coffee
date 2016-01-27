Accounts.validateNewUser (newUser) ->

    createUser = false

    newUserDecorated = new MeteorUser newUser
    connectionId = Helpers.Server.Auth.GetCurrentConnectionId()

    role = null
    if connectionId
        role = Helpers.Server.Session.Get 'signup_role', true

    # If there is no active connection, just trust the creation (coming from the server)
    if not connectionId or newUser.profile.migrated_from
        createUser = true
    else
        # If the user is already logged in, attach the new services
        servicesIntersection = _.intersection(MeteorUser.getProviders(), Object.keys(newUser.services || {}))

        if servicesIntersection.length
            if Meteor.userId()
                currentUser = new MeteorUser Meteor.user()
                currentUser.attachServices newUser.services
                newUser = currentUser._user
                newUserDecorated = new MeteorUser newUser
                createUser = false
            else
                existingUser = Meteor.users.findOne {
                    email: newUserDecorated.getEmail()
                }

                if existingUser
                    existingUser = new MeteorUser existingUser
                    existingUser.attachServices newUser.services
                    Helpers.Server.Session.Set SESSION_KEY_CONNECTED_USER_ID, existingUser._id, false, true
                    newUser = existingUser._user
                    newUserDecorated = new MeteorUser newUser
                    createUser = false
                else
                    createUser = true
        else
            if Meteor.userId()
                newUser = Meteor.user()
                newUserDecorated = new MeteorUser newUser
                createUser = false # trying to signup again ?!?
            else
                createUser = true

        # if the user comes from LinkedIn, we enrich the linkedin profile right away
        if newUser.services.linkedin

            try
                linkedinService = Crater.Services.Get Services.LINKEDIN
                profileInfo = linkedinService.getProfileInfo newUser
                updateObj = _.extend {}, newUser.services.linkedin
                updateObj.profile = profileInfo

                if createUser
                    newUser.services.linkedin = updateObj
                else
                    user = new MeteorUser newUser
                    user.update {
                        $set:
                            'services.linkedin': updateObj
                    }
            catch e

        if newUser.services?.facebook
            if not newUser.services.facebook.email
                return false

    if createUser

        if role and role isnt 'admin'
            newUser.roles ||= []
            newUser.roles.push role

        newUser = _.extend(newUser, newUserDecorated.initCoreProperties())

    return createUser
