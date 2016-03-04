Accounts.config {
   forbidClientAccountCreation : true
}

# Building Settings shared with client

clientSettings = {}

if Meteor.settings.forClient
    for forClient in Meteor.settings.forClient
        clientSettings[forClient] = Meteor.settings[forClient]

Inject.obj 'ServerSettings', clientSettings

if Meteor.settings.GTM #if there is a Google Tag Manager key in the settings, inject it just after the <body>. Remember to declare globally dataLayer = [] in your code.

    googleTagManagerScript = '<noscript><iframe src="//www.googletagmanager.com/ns.html?id=' + Meteor.settings.GTM + '" height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>' + "<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
            new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
            j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
            '//www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
    })(window,document,'script','dataLayer', '" + Meteor.settings.GTM + "');</script>"

    Inject.rawBody('googleTagManagerScript', googleTagManagerScript)

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
