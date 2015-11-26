Helpers.Client.TemplatesHelper.Handle('user_forgot_password', (template) =>

    forgotPasswordFormSchema = null

    template.onCustomCreated = ->
        forgotPasswordFormSchema = Crater.Schema.Get Crater.Schema.Account.EmailForgotPassword
        translate('view.forgot_password.no_email')
        translate('view.forgot_password.success_message')

    template.helpers {
        'schema': ->
            forgotPasswordFormSchema
    }

    AutoForm.hooks {
        userForgotPasswordForm: Helpers.Client.Form.GetFormHooks {
            before:
                insert: ->

                    form = $('#userForgotPasswordForm')
                    email = $.trim(form.find('[name="email"]').val())

                    Helpers.Client.MeteorHelper.CallMethod {
                        method: 'sendNewPasswordLink'
                        params: [email]
                        callback: (error, result) =>
                            if not result
                                Helpers.Client.Notifications.Error translate('view.forgot_password.no_email')
                            else
                                Helpers.Client.Notifications.Success translate('view.forgot_password.success_message')
                                Router.go 'presentation.account.login'
                    }

                    false
        }
    }

)