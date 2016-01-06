@Feature_Users = {}
globalContext = @

class @Feature_Users.Helpers

    @EnsureLoginForConnectedService = (callback) =>
        globalContext.Helpers.Client.MeteorHelper.CallMethod {
            method: 'loginConnectedUser'
            callback: callback
        }

    @EnsurePostSignupOps = =>
        if Meteor.userId() and not Meteor.user()?.platform?.post_signup_executed
            globalContext.Helpers.Log.Info 'Executing post Signup'
            globalContext.Helpers.Client.MeteorHelper.CallMethod {
                method: 'ensurePostSignupOps'
                background: true
            }

    @OnLoggedIn = (before) =>

        subManager.reset()
        subManager.clear()

        globalContext.Helpers.Log.Info 'On Logged In'

        onPostBefore = =>
            @EnsurePostSignupOps()

            redirect = Router.current()?.params?.query?.redirect

            if redirect
                location.href = redirect

        if before
            globalContext.Helpers.Log.Info 'On Before'
            before onPostBefore
        else
            onPostBefore()

    @OnLogin = (before) =>

        globalContext.Helpers.Log.Info 'OnLogin'

        isLoggedIn = Meteor.userId()

        if isLoggedIn
            globalContext.Helpers.Log.Info 'Is Already Logged In'
            @OnLoggedIn before
        else
            globalContext.Helpers.Log.Info 'Ensuring Login'
            @EnsureLoginForConnectedService (error, result) =>
                globalContext.Helpers.Log.Info 'Ensured Login'
                if result
                    globalContext.Helpers.Log.Info 'Setting as Logged In'
                    globalContext.Helpers.Client.Auth.SetAsLoggedIn result, =>
                        @OnLoggedIn before
