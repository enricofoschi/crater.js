Meteor.autorun ->
    if Meteor.status().connected
        Helpers.Client.SessionHelper.EnsureToken()

Meteor.startup ->
    window.setInterval Helpers.Client.SessionHelper.EnsureToken, 60000