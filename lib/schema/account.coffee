@Crater.Schema.Account = {}

@Crater.Schema.Account.EmailSignup = ->
    {
        firstName: {
            type: String
            label: Helpers.Translation.Translate('user.first_name')
            max: 50
        }
        lastName: {
            type: String
            label: Helpers.Translation.Translate('user.last_name')
            max: 50
        },
        email: {
            type: String,
            regEx: SimpleSchema.RegEx.Email
            label: Helpers.Translation.Translate('user.email')
        },
        password: {
            type: String
            label: Helpers.Translation.Translate('user.password')
            max: 10
    }
}