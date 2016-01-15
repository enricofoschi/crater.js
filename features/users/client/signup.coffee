Helpers.Client.TemplatesHelper.Handle('user_signup', (template) =>

    signupFormSchema = null

    template.onCustomCreated = ->
        signupFormSchema = Crater.Schema.Get Template.instance().data.schema || Crater.Schema.Account.EmailSignup

        # Preloading translations
        translate('view.signup.error.email_already_present')

    template.events {

        'click .btn-login-linkedin' : (e, t) ->
            Helpers.Client.Auth.LoginWith 'LinkedIn', template.uniqueInstance.data.before

        'click .btn-login-xing' : (e, t) ->
            Helpers.Client.Auth.LoginWith 'Xing', template.uniqueInstance.data.before

        'click .btn-login-google' : (e, t) ->
            Helpers.Client.Auth.LoginWith 'Google', template.uniqueInstance.data.before

        'click .btn-login-facebook' : (e, t) ->
            Helpers.Client.Auth.LoginWith 'Facebook', template.uniqueInstance.data.before
    }

    template.helpers {
        formClass: ->
            return if not @twoColumns then 'form-horizontal' else ''

        schema: ->
            return signupFormSchema

        emailMethod: ->
            return @emailMethod || 'createUserWithEmail'

        cta: ->
            return @ctaCopy || translate('view.signup.email_signup_cta')
    }

    AutoForm.hooks {
        emailSignupForm: Helpers.Client.Form.GetFormHooks {
            onSuccess: (formType, result) ->
                if not result
                    Helpers.Client.Form.ShowGeneralError.apply @, arguments
                else if result is 'NOT_UNIQUE_EMAIL'
                    Helpers.Client.Notifications.Error(translate('view.signup.error.email_already_present'))
                else
                    Helpers.Client.Loader.Show()
                    form = $('#emailSignupForm')
                    email = $.trim(form.find('[name="email"]').val()).toLowerCase()
                    password = $.trim(form.find('[name="password"]').val())

                    Meteor.loginWithPassword(email, password, (error) ->

                        if error
                            Helpers.Client.Loader.Hide()
                            Helpers.Client.Form.ShowGeneralError.apply @, arguments
                        else
                            Feature_Users.Helpers.OnLogin((onPostBefore) ->

                                verifyEmail = ->
                                    Helpers.Client.MeteorHelper.CallMethod {
                                        method: 'sendEmailVerificationRequest'
                                        background: true
                                    }

                                if template.uniqueInstance.data.before
                                    template.uniqueInstance.data.before(->
                                        Helpers.Client.Loader.Hide()
                                        onPostBefore()
                                    )
                                else
                                    Helpers.Client.Loader.Hide()
                                    onPostBefore() if onPostBefore

                                verifyEmail()
                            )
                    );
        }
    }
)