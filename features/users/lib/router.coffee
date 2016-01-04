# Controllers
Crater.Routing.Controllers.LoggedInController = Helpers.Router.AddController {
    name: 'loggedin'
    extends: Crater.Routing.Controllers.Presentation
    layoutTemplate: 'PresentationLayout'
    waitOn: ->
        Helpers.Log.Tick('LoggedIn WO')
        Crater.Routing.Controllers.LoggedInController.DefaultSubscriptions || []
    onBeforeAction: ->
        Helpers.Log.Tick('LoggedIn OBA')
        if not Meteor.userId()
            Router.go 'presentation.account.login', null, {
                query: 'redirect=' + encodeURIComponent(location.href)
            }
        else
            @next()

}

# Routes
Helpers.Router.AddRoute {
    path: 'login'
    name: 'presentation.account.login'
    tracking:
        pageName: 'login'
    controller: Crater.Routing.Controllers.Presentation
    onBeforeAction: ->
        if Meteor.userId()
            if redirect = @params?.query?.redirect
                location.href = r edirect
            else
                Helpers.Log.Info 'Redirecting to loggedin from login'
                Helpers.Client.Auth.OnLoggedInRedirect()
        else
            @next()
    action: ->
        @.render 'presentation.account.login'
        return
}

Helpers.Router.AddRoute {
    path: 'forgot-password'
    name: 'presentation.account.forgot_password'
    controller: Crater.Routing.Controllers.Presentation
    onBeforeAction: ->
        if Meteor.userId()
            Router.go 'presentation.account.forgot_password'
        else
            @next()
    action: ->
        @.render 'presentation.account.forgot_password'
        return
}

Helpers.Router.AddRoute {
    path: 'reset-password/:id/:token'
    name: 'presentation.account.reset_password'
    controller: Crater.Routing.Controllers.Presentation
    waitOn: ->
        [
            subManager.subscribe 'reset_password_user', @params.id, @params.token
        ]
    action: ->
        @.render 'presentation.account.reset_password'
        return
}

Helpers.Router.AddRoute {
    path: 'verify-email/:token'
    name: 'presentation.account.verify_email'
    controller: Crater.Routing.Controllers.LoggedInController
    action: ->
        @render 'presentation.account.verify_email', {
            data: {
                token: @params.token
            }
        }
}
