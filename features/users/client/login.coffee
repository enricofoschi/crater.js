Helpers.Client.TemplatesHelper.Handle('user_login', (template) =>

    loginFormSchema = null

    template.onCustomCreated = ->
        loginFormSchema = Crater.Schema.Get Crater.Schema.Account.EmailLogin
        translate('view.login.error.incorrect_password')

    template.events {

        'click .btn-login-linkedin' : (e, t) ->
            Helpers.Client.Auth.LoginWith 'LinkedIn', template.uniqueInstance.data?.before

        'click .btn-login-xing' : (e, t) ->
            Helpers.Client.Auth.LoginWith 'Xing', template.uniqueInstance.data?.before

        'click .btn-login-google' : (e, t) ->
            Helpers.Client.Auth.LoginWith 'Google', template.uniqueInstance.data?.before

        'click .btn-login-facebook' : (e, t) ->
            Helpers.Client.Auth.LoginWith 'Facebook', template.uniqueInstance.data?.before
    }

    template.helpers {
        schema: ->
            return loginFormSchema

        noSocial: ->
            return ServerSettings.platform?.noSocialLogins
    }


    AutoForm.hooks {
        userLoginForm: Helpers.Client.Form.GetFormHooks {
            before:
                insert: ->

                    form = $('#userLoginForm')
                    email = $.trim(form.find('[name="email"]').val()).toLowerCase()
                    password = $.trim(form.find('[name="password"]').val())

                    loginUser = =>
                        Meteor.loginWithPassword(email, password, (e) ->
                            Feature_Users.Helpers.OnLogin(template.uniqueInstance.data?.before)
                        );

                    loginUser()

                    return false
        }
    }

)