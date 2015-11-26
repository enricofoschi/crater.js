@Crater.Schema.Account = {}

@Crater.Schema.Account.EmailSignup = ->
    {
    firstName:
        type: String
        label: ->
            translate 'user.first_name'
        max: 50
    lastName:
        type: String
        label: ->
            translate 'user.last_name'
        max: 50
    email:
        type: String,
        regEx: SimpleSchema.RegEx.Email
        label: ->
            translate 'user.email'
        max: 200
    password:
        type: String
        label: ->
            translate 'user.password'
        max: 25
    }

@Crater.Schema.Account.EmailLogin = ->
    {
    email:
        type: String
        label: ->
            translate 'user.email'
    password:
        type: String
        label: ->
            translate 'user.password'
    }

@Crater.Schema.Account.EmailForgotPassword = ->
    {
    email:
        type: String
        label: translate 'user.email'
        max: 200
    }

@Crater.Schema.Account.ResetPassword = ->
    {
    password:
        type: String
        label: translate 'user.password'
    password2:
        type: String
        label: translate 'views.reset_password.confirm_password'
        custom: ->
            if @value isnt @field('password').value
                return "passwordMismatch"
    }

@Crater.Schema.Account.MainSettings = ->
    {
    first_name:
        type: String
        label: translate 'user.first_name'
        max: 50
    last_name:
        type: String
        label: translate 'user.last_name'
        max: 50
    phone:
        type: String
        label: translate 'user.phone'
    skype:
        type: String
        label: translate 'user.skype'
        optional: true
    role:
        type: String
        label: translate 'user.role'
        optional: true
    email:
        regEx: SimpleSchema.RegEx.Email
        type: String
        label: translate 'user.email'
        max: 200
    password:
        type: String
        label: translate 'presentation.account.settings.new_password'
        optional: true
    password2:
        type: String
        label: translate 'presentation.account.settings.confirm_new_password'
        optional: true
        custom: ->
            if @value isnt @field('password').value
                return "passwordMismatch"
    }