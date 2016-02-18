Helpers.Client.TemplatesHelper.Handle('cookiebar', (template) =>
    template.helpers {
        cookiebarShown: ->
            user = MeteorUser.GetCurrentUser()
            (Helpers.Client.Storage.Get('cookiebarShown') is '1') or user.platform?.cookiebar_shown
    }

    template.events {
        'click .btn-close': ->
            user = MeteorUser.GetCurrentUser()

            Helpers.Client.Storage.Set 'cookiebarShown', '1'

            if not user.anonymous and not user.platform?.cookiebar_shown
                Helpers.Client.MeteorHelper.CallMethod {
                    method: 'users.cookiebarShown'
                }

            $('#cookiebar').animate({'opacity': 0}, 300,()->
                $(@).remove()
            )
    }
)
