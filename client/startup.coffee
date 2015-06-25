@Crater.ConnectedPromise = $.Deferred()

Crater.beforeStartup(@Crater.ConnectedPromise, 1)

# Token Management
Meteor.autorun ->
    if Meteor.status().connected
        Helpers.Client.SessionHelper.EnsureToken (e, r) =>
            if e
                Crater.ConnectedPromise.reject()
            else
                Crater.ConnectedPromise.resolve()

Meteor.startup ->
    Helpers.Client.TemplatesHelper.DecorateTemplates()
    window.setInterval Helpers.Client.SessionHelper.EnsureToken, 60000

