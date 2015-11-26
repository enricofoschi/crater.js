BrowserPolicy.content.allowOriginForAll 'https://*.googleapis.com'
BrowserPolicy.content.allowOriginForAll 'http://*.googleapis.com'
BrowserPolicy.content.allowOriginForAll 'https://*.gstatic.com'
BrowserPolicy.content.allowOriginForAll 'http://*.gstatic.com'
BrowserPolicy.content.allowOriginForAll 'https://s3.eu-central-1.amazonaws.com'
BrowserPolicy.content.allowOriginForAll 'https://*.googleapis.com'
BrowserPolicy.content.allowOriginForAll 'https://*.gstatic.com'
BrowserPolicy.content.allowOriginForAll 'https://*.gstatic.com'
BrowserPolicy.content.allowOriginForAll 'http://*.segment.com'
BrowserPolicy.content.allowOriginForAll 'https://*.segment.com'
BrowserPolicy.content.allowOriginForAll 'http://*.google-analytics.com'
BrowserPolicy.content.allowOriginForAll 'https://*.google-analytics.com/'
BrowserPolicy.content.allowOriginForAll 'http://*.kissmetrics.com'
BrowserPolicy.content.allowOriginForAll 'https://*.kissmetrics.com'
BrowserPolicy.content.allowOriginForAll 'https://s3.amazonaws.com/scripts.kissmetrics.com'
BrowserPolicy.content.allowOriginForAll 'http://*.kissmetrics.com'
BrowserPolicy.content.allowOriginForAll 'https://*.kissmetrics.com'
BrowserPolicy.content.allowOriginForAll 'https://*.ravenjs.com/'
BrowserPolicy.content.allowOriginForAll 'http://*.ravenjs.com/'
BrowserPolicy.content.allowOriginForAll 'https://*.getsentry.com/'
BrowserPolicy.content.allowOriginForAll 'http://*.cloudflare.com/'
BrowserPolicy.content.allowOriginForAll 'https://*.cloudflare.com/'
BrowserPolicy.content.allowOriginForAll 'https://*.g.doubleclick.net/'
BrowserPolicy.content.allowOriginForAll 'https://*.errorception.com/'
BrowserPolicy.content.allowOriginForAll 'http://*.errorception.com/'
BrowserPolicy.content.allowOriginForAll 'https://*.intercom.io'
BrowserPolicy.content.allowOriginForAll 'https://*.intercomcdn.com/'
BrowserPolicy.content.allowOriginForAll 'https://*.intercomassets.com'
BrowserPolicy.content.allowOriginForAll 'https://d2lupf3iayb77w.cloudfront.net/'
BrowserPolicy.content.allowOriginForAll 'https://maxcdn.bootstrapcdn.com/'
BrowserPolicy.content.allowOriginForAll 'http://maxcdn.bootstrapcdn.com/'
BrowserPolicy.content.allowOriginForAll 'http://*.mxpnl.com'
BrowserPolicy.content.allowOriginForAll 'https://*.mxpnl.com'
BrowserPolicy.content.allowOriginForAll 'https://d3vebn31ck2z4a.cloudfront.net/'
BrowserPolicy.content.allowOriginForAll 'https://*.cloudfront.net/'
BrowserPolicy.content.allowOriginForAll 'https://*.googleadservices.com'
BrowserPolicy.content.allowOriginForAll 'https://*.google.com/'
BrowserPolicy.content.allowOriginForAll 'https://*.google.nl/'
BrowserPolicy.content.allowOriginForAll 'https://*.google.co.uk/'
BrowserPolicy.content.allowOriginForAll 'https://*.google.de/'
BrowserPolicy.content.allowOriginForAll 'https://*.google.pl/'
BrowserPolicy.content.allowOriginForAll 'https://*.google.cr/'
BrowserPolicy.content.allowOriginForAll 'https://*.google.dk/'
BrowserPolicy.content.allowOriginForAll 'https://*.google.ie/'
BrowserPolicy.content.allowOriginForAll 'https://*.facebook.net'
BrowserPolicy.content.allowOriginForAll 'http://*.facebook.net'
BrowserPolicy.content.allowOriginForAll 'https://*.facebook.com'
BrowserPolicy.content.allowOriginForAll 'http://d24n15hnbwhuhn.cloudfront.net'
BrowserPolicy.content.allowOriginForAll 'https://d24n15hnbwhuhn.cloudfront.net'
BrowserPolicy.content.allowOriginForAll 'http://cdn.heapanalytics.com'
BrowserPolicy.content.allowOriginForAll 'https://cdn.heapanalytics.com'
BrowserPolicy.content.allowOriginForAll 'http://d26b395fwzu5fz.cloudfront.net'
BrowserPolicy.content.allowOriginForAll 'https://d26b395fwzu5fz.cloudfront.net'
BrowserPolicy.content.allowOriginForAll 'https://api.keen.io'
BrowserPolicy.content.allowOriginForAll 'http://heapanalytics.com'
BrowserPolicy.content.allowOriginForAll 'https://heapanalytics.com'

for url in Meteor.settings.policies.allow
   BrowserPolicy.content.allowOriginForAll url
BrowserPolicy.content.allowEval()

Accounts.config {
   forbidClientAccountCreation : true
}

Meteor.startup ->
   UploadServer.init {
       tmpDir: Meteor.settings.tmpFolder
       uploadDir: Meteor.settings.uploadFolder
       checkCreateDirectories: false
       maxFileSize: 25000000
       cacheTime: 0
   }

# Building Settings shared with client
clientSettings = {}
if Meteor.settings.forClient
    for forClient in Meteor.settings.forClient
        clientSettings[forClient] = Meteor.settings[forClient]

Inject.obj 'ServerSettings', clientSettings

Crater.startup ->
    elasticSearchServices = Crater.Services.Get Services.ELASTIC_SEARCH
    elasticSearchServices.ensureIndex()

Inject.rawModHtml 'setupAssets', (html) ->

    originalHtml = html

    try
        if Meteor.settings.urls.cdn
            html = html.replace /<link rel="stylesheet" type="text\/css" class="__meteor-css__" href="\//g, '<link rel="stylesheet" type="text/css" class="__meteor-css__" href="' + Meteor.settings.urls.cdn
            html = html.replace /<script type="text\/javascript" src="\//g, '<script type="text/javascript" src="' + Meteor.settings.urls.cdn

        return html
    catch e
        # glup

    return originalHtml
