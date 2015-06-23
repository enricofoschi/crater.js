@Crater.Schema.Account = {}

@Crater.Schema.Account.EmailSignup = ->
    {
    firstName: {
        type: String
        label: translate 'commons.user.first_name'
        max: 50
    }
    lastName: {
        type: String
        label: translate 'commons.user.last_name'
        max: 50
    },
    email: {
        type: String,
        regEx: SimpleSchema.RegEx.Email
        label: translate 'commons.user.email'
    },
    password: {
        type: String
        label: translate 'commons.user.password'
        max: 10
    }
    }

@Crater.Schema.Account.LogIn = ->
    {
    email: {
        type: String
        label: translate 'commons.user.email'
        max: 200
    }
    }