Accounts.validateNewUser (newUser) ->

    retVal = false

    if Meteor.userId()
        currentUser = new MeteorUser Meteor.user()
        currentUser.attachServices newUser.services
        newUser = currentUser
    else
        retVal = true

    if newUser.services.linkedin
        linkedinService = Crater.Services.Get Services.LINKEDIN
        profileInfo = linkedinService.getProfileInfo newUser
        updateObj = _.extend {}, newUser.services
        updateObj.linkedin.profile = profileInfo
        Meteor.users.update newUser._id, updateObj

    return retVal