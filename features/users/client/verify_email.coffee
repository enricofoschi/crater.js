Helpers.Client.TemplatesHelper.Handle('presentation.account.verify_email', (template) =>

    template.onCustomCreated = =>
        errorMsg = translate 'presentation.account.verify_email.error'
        successMsg = translate 'presentation.account.verify_email.success'

        Helpers.Client.MeteorHelper.CallMethod {
            method: 'verifyUserEmail'
            params: [
                Template.instance().data.token
            ]
            callback: (error, result) ->
                console.log arguments
                if error or not result.success
                    Helpers.Client.Notifications.Error errorMsg
                else
                    console.log 'DONE'
                    Helpers.Client.Notifications.Success successMsg

                Helpers.Log.Info 'Redirecting to loggedin from verifiedByEmail'
                Helpers.Client.Auth.OnLoggedInRedirect()
        }
)