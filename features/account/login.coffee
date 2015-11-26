Helpers.Client.TemplatesHelper.Handle('presentation.account.login', (template) =>
    template.helpers {
        signupNow: ->
            translate 'presentation.account.login.no_account', {
                link: '<a href="' + Helpers.Router.Path('presentation.signup') + '">' + translate('presentation.account.login.signup_now') + '</a>'
            }
    }
)