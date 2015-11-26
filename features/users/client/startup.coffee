Crater.startup ->

    queryString = Helpers.Router.GetQueryString()
    autoLoginUserId = queryString.autologin_userid
    autoLoginUserToken = queryString.autologin_token
    Helpers.Client.Auth.SetUtmInfo()


    if autoLoginUserId

        onLoggedIn = ->
            if queryString.ftuf is '1'
                Session.set('allowFTUF', '1')

            if queryString.redirect
                Router.go queryString.redirect

        if not Meteor.userId()
            Helpers.Client.MeteorHelper.CallMethod {
                method: 'user.autoLogin'
                params: [
                    autoLoginUserId
                    autoLoginUserToken
                ]
                callback: (error, result)->
                    if not error
                        Helpers.Client.Auth.SetAsLoggedIn result, ->
                            onLoggedIn()
            }
        else
            onLoggedIn()

    if Helpers.Client.Auth.IsSpoofing()

        isAdmin = Roles.userIsInRole Meteor.userId(), 'admin'
        userToSpoof = Helpers.Router.GetQueryString().spoof

        if userToSpoof and isAdmin and Meteor.userId() isnt userToSpoof

            Helpers.Client.MeteorHelper.CallMethod {
                method: 'loginAsUser'
                params: [
                    userToSpoof
                ]
                callback: (error, result)->

                    if not error
                        Helpers.Client.Auth.SetAsLoggedIn result
            }