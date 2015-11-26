global = @
global.CurrentTemplateLayout = new ReactiveVar()
@subManager = new SubsManager {
    cacheLimit: 500
    expireIn: 15
}

@Crater.Routing = {
    Controllers: {}
}

Router.configure {
    loadingTemplate: 'loader'
    notFoundTemplate: '_404'
    waitOn: ->
        [
            subManager.subscribe 'roles'
            Meteor.subscribe 'available_users'
        ]
}

# Base Controller
languageInitialised = null
metaLinkRefs = {}

@Crater.Routing.Controllers.Base = Helpers.Router.AddController {
    onBeforeAction: ->

        query = Helpers.Router.GetQueryString()

        # Redirecting user to right language, if one has been chosen previously
        forcing = query.setLanguage is 'true'
        alreadyRedirected = query.langRedirect is 'true'
        phantom = query.___isRunningPhantomJS___ is 'true'
        currentLang = Helpers.Translation.GetUserLanguage()
        redirected = false
        languageToChangeTo = null

        if not alreadyRedirected and not forcing and not Helpers.Client.Auth.IsSpoofing() and not ServerSettings.phantomOpen and not phantom
            # Prioritising user language
            if Meteor.userId()
                user = new MeteorUser Meteor.user()

                if user.lang_forced and currentLang isnt user.lang
                    languageToChangeTo = user.lang
            # Then session language
            else
                sessionLang = Helpers.Client.SessionHelper.Get Helpers.Translation.LANGUAGE_KEY
                sessionLangForced = Helpers.Client.SessionHelper.Get Helpers.Translation.LANGUAGE_FORCED_KEY

                if sessionLangForced and sessionLang isnt currentLang
                    languageToChangeTo = sessionLang

            if languageToChangeTo
                redirected = true
                Helpers.Router.HardGo @route, @params, {
                    lang: languageToChangeTo
                    query: Helpers.Router.GetQueryString()
                }

        if not redirected
            @next()
    waitOn: ->
        lang = Helpers.Translation.GetUserLanguage()
        Helpers.Router.SetCurrentRouteName Helpers.Translation.CleanRouteName @route?.getName()

        if Meteor.isClient
            # setting main html lang
            if not languageInitialised
                languageInitialised = true
                $('html').attr('lang', lang)

                head = $('head')

                for language in ServerSettings.languages when language isnt ServerSettings.defaultLanguage
                    newLinkRef = $('<link rel="alternate" hreflang="' + language + '" href="" />')
                    head.append newLinkRef
                    metaLinkRefs[language] = newLinkRef

            # setting ref to alternative languages
            for own language, linkRef of metaLinkRefs
                linkRef.attr 'href', Helpers.Router.Path @route, @params, {
                    lang: language
                    absolute: true
                }

        retVal = []

        if Meteor.isClient
            retVal.push Helpers.Promises.FromPromisesToWaitOnHandle "craterStarted", [
                Crater._startedDeferred.promise()
            ]

        retVal
}

@Crater.Routing.Controllers.Presentation = Helpers.Router.AddController {
    name: 'presentation'
    layoutTemplate: 'PresentationLayout'
    bodyClass: 'layout-presentation'
    extends: Crater.Routing.Controllers.Base
}

@Crater.Routing.Controllers.LoggedOutController = Helpers.Router.AddController {
    name: 'loggedout'
    extends: Crater.Routing.Controllers.Presentation
    layoutTemplate: 'PresentationLayout'
    onBeforeAction: ->
        if Meteor.userId()
            Helpers.Log.Info 'Redirecting to loggedin from loggedout'
            Helpers.Client.Auth.OnLoggedInRedirect()
        @next()
}
