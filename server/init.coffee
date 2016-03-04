Accounts.config {
   forbidClientAccountCreation : true
}

# Building Settings shared with client

clientSettings = {}

if Meteor.settings.forClient
    for forClient in Meteor.settings.forClient
        clientSettings[forClient] = Meteor.settings[forClient]

Inject.obj 'ServerSettings', clientSettings

if Meteor.settings.GTM #if there is a Google Tag Manager key in the settings, add the iframe for it
    iframeGTM = '<noscript><iframe src="//www.googletagmanager.com/ns.html?id=' + Meteor.settings.GTM + '" height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>'
    Inject.rawBody('iframeGTM', iframeGTM)

Crater.startup ->
    elasticSearchServices = Crater.Services.Get Services.ELASTIC_SEARCH
    elasticSearchServices.ensureIndex()

Inject.rawModHtml 'setupAssets', (html) ->

    originalHtml = html

    try
        if Meteor.settings.urls.cdn
            html = html.replace /<link rel="stylesheet" type="text\/css" class="__meteor-css__" href="\//g, '<link rel="stylesheet" type="text/css" class="__meteor-css__" href="' + Meteor.settings.urls.cdn
            html = html.replace /href="\/img\//g, 'href="' + Meteor.settings.urls.cdn + 'img/'
            html = html.replace /<script type="text\/javascript" src="\//g, '<script type="text/javascript" src="' + Meteor.settings.urls.cdn

        return html
    catch e
        # glup

    return originalHtml
