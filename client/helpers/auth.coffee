class @Helpers.Client.Auth

    @IsLoggedIn: ->
        Helpers.Client.SessionHelper.Get 'loggedIn'