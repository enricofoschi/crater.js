Helpers.Client.TemplatesHelper.Handle('presentation.account.verify_email', (template) =>

    template.onCustomCreated = ->
        errorMsg = translate 'presentation.account.verify_email.error'
        successMsg = translate 'presentation.account.verify_email.success'

        Helpers.Client.MeteorHelper.CallMethod {
            method: 'users.verifyEmail'
            params: [
                @data.token
                Helpers.Router.GetQueryString().newEmail
            ]
            callback: (error, result) ->
                if error or not result.success
                    Helpers.Client.Notifications.Error errorMsg
                else
                    Helpers.Client.Notifications.Success successMsg

                Helpers.Log.Info 'Redirecting to loggedin from verifiedByEmail'
                Helpers.Client.Auth.OnLoggedInRedirect()
        }
)