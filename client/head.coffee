faviconRender = ->
    imgPath = ServerSettings.urls.imgs

    output = ''

    output += '<link rel="shortcut icon" sizes="16x16 24x24 32x32 48x48 64x64" href="{{imgPath}}favicon/favicon.ico">'


    if ServerSettings.head?.touchIcons?.length
        for res in ServerSettings.head.touchIcons
            output += '<link rel="apple-touch-icon" sizes="' + res + 'x' + res '" href="{{imgPath}}favicon/favicon-' + res + '.png">'


    output += '<meta content="yes" name="apple-mobile-web-app-capable">'
    output += '<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">'
    output += '<meta name="application-name" content="' + ServerSettings.titleSuffix + '">'
    output = output.replace(/\{\{imgPath\}\}/g, imgPath)
    document.write output
    return

spoofingSetup = false
if window.location.search.indexOf('spoofing=true') > -1 and !spoofingSetup
    spoofingSetup = true
    _getItem = undefined
    _setItem = undefined
    _setItem = Storage::setItem
    _getItem = Storage::getItem

    Storage::getItem = (k) ->
        if this == window.localStorage
            window.sessionStorage.getItem.apply sessionStorage, arguments
        else
            _getItem.apply this, arguments

    Storage::setItem = (k, v) ->
        if this == window.localStorage
            window.sessionStorage.setItem.apply sessionStorage, arguments
        else
            _setItem.apply this, arguments

faviconRender()
