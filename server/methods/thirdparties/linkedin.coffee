Meteor.methods {
    'linkedin.getProfileInfo': ->
        linkedinService = Crater.Services.Get Services.LINKEDIN
        linkedinService.getProfileInfo(Meteor.userId())
}