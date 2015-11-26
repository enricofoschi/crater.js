Helpers.Client.TemplatesHelper.Handle('user_reset_password', (template) =>

    resetPasswordFormSchema = null
    user = null

    template.onCustomCreated = ->

        translate('view.reset_password.invalid_link')

        resetPasswordFormSchema = Crater.Schema.Get Crater.Schema.Account.ResetPassword

        user = Meteor.users.findOne {
            _id: Router.current().params.id
            password_reset_token: Router.current().params.token
        }

        if not user
            Helpers.Client.Notifications.Error translate('view.reset_password.invalid_link')
            Router.go 'presentation.account.forgot_password'

    template.helpers {
        'schema': ->
            resetPasswordFormSchema
    }

    AutoForm.hooks {
        userResetPasswordForm: Helpers.Client.Form.GetFormHooks {
            before:
                insert: ->

                    form = $('#userResetPasswordForm')
                    password = $.trim(form.find('[name="password"]').val())

                    Helpers.Client.MeteorHelper.CallMethod {
                        method: 'setNewUserPassword'
                        params: [
                            Router.current().params.id
                            Router.current().params.token
                            password
                        ]
                        callback: (error, result) =>
                            if result
                                Helpers.Client.Notifications.Success translate('view.reset_password.success_message')
                                Router.go 'presentation.account.login'
                    }

                    false
        }
    }

)