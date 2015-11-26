Helpers.Translation.OnCommonTranslationsLoaded ->
    SimpleSchema.messages {
        required: translate("commons.validation.is_required")
        passwordMismatch: translate("commons.validation.password_mismatch")
        regEx: [
            {
                msg: "[label] failed regular expression validation"
            }
            {
                exp: SimpleSchema.RegEx.Email, msg: translate("commons.validation.valid_email")
            }
            {
                exp: SimpleSchema.RegEx.WeakEmail, msg: "[label] must be a valid e-mail address"
            }
            {
                exp: SimpleSchema.RegEx.Domain, msg: "[label] must be a valid domain"
            }
            {
                exp: SimpleSchema.RegEx.WeakDomain, msg: "[label] must be a valid domain"
            }
            {
                exp: SimpleSchema.RegEx.IP, msg: "[label] must be a valid IPv4 or IPv6 address"
            }
            {
                exp: SimpleSchema.RegEx.IPv4, msg: "[label] must be a valid IPv4 address"
            }
            {
                exp: SimpleSchema.RegEx.IPv6, msg: "[label] must be a valid IPv6 address"
            }
            {
                exp: SimpleSchema.RegEx.Url, msg: "[label] must be a valid URL"
            }
            {
                exp: SimpleSchema.RegEx.Id, msg: "[label] must be a valid alphanumeric ID"
            }
        ]
    }