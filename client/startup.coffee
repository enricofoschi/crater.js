# Token Management
Meteor.autorun ->
    if Meteor.status().connected
        Helpers.Client.SessionHelper.EnsureToken()

Meteor.startup ->
    Helpers.Client.TemplatesHelper.DecorateTemplates()
    window.setInterval Helpers.Client.SessionHelper.EnsureToken, 60000