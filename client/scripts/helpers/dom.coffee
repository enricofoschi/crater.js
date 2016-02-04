globalContext = @

class @Helpers.Client.DOM

    textSeparators = [
        188 # ,
    ]

    # Move to forms
    @OnEnterKey: (source, callback, onBlur, useTextSeparator, skipReset) ->

        source.keydown (e) ->
            usingTextSeparator = (useTextSeparator and e.which in textSeparators)
            if e.which is 13 or usingTextSeparator
                callback.apply @, arguments
                if not skipReset
                    source.val('')
                    e.preventDefault()
                source.get(0).focus()

        if onBlur
            source.blur ->
                callback.apply @, arguments
                if not skipReset
                    source.val('')


    # Move to forms
    @OnDelayedKeyPress: (sources, callback, identifier) =>

        check identifier, String

        sources.each ->
            source = $(@)

            pressedKey = identifier + '-pressed'
            timeoutIdentifier = identifier + '-keypresstimeout'

            if identifier
                if source.data identifier + '-initialised'
                    return
                else
                    source.data identifier + '-initialised', true

            delay = 1100
            resetTimeout = ->
                if source.data timeoutIdentifier
                    Meteor.clearTimeout source.data timeoutIdentifier

            setTimer = ->
                source.data pressedKey, (new Date()).getTime()

            source.keyup ->
                lastPress = source.data pressedKey

                if not lastPress
                    callback.apply source
                else
                    timePassed = (new Date()).getTime() - lastPress

                    if  timePassed > delay
                        callback.apply source
                        resetTimeout()
                    else
                        resetTimeout()
                        source.data timeoutIdentifier, Meteor.setTimeout ->
                            callback.apply source
                            setTimer()
                        , delay - timePassed

                setTimer()

            source.blur callback
            source.change callback

    jsLoading = {}

    @LoadJS: (properties) =>

        if jsLoading[properties.identifier]
            jsLoading[properties.identifier].promise.then properties.callback
        else
            deferred = $.Deferred()

            jsLoading[properties.identifier] = {
                promise: deferred.promise()
            }

            jsLoading[properties.identifier].promise.then properties.callback

            Helpers.Client.Loader.Show() if properties.blockUI

            $.ajax {
                url: properties.url
                dataType: "script"
                success: ->
                    Helpers.Client.Loader.Hide() if properties.blockUI
                    deferred.resolve()
                cache: true
            }

            if properties.onLoad
                properties.onLoad()


    @LoadCSS: (url) =>
        $('head').append('<link rel="stylesheet" type="text/css" href="' + url + '">');

    @LoadFont: (font) =>
        globalContext.WebFontConfig = {
            google:
                families: [font]
        }
        wf = document.createElement('script')
        wf.src = 'https://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js'
        wf.type = 'text/javascript';
        s = document.getElementsByTagName('script')[0]
        s.parentNode.insertBefore(wf, s)

    @GetCaretPosition: (input) ->
        if input.selectionStart
            return input.selectionStart
        else if document.selection
            input.focus();
            sel = document.selection.createRange()
            selLen = document.selection.createRange().text.length
            sel.moveStart('character', -input.value.length)
            return sel.text.length - selLen

    @SetCaretPosition: (input, position) ->
        if input.setSelectionRange
            input.focus()
            input.setSelectionRange(position, position);
        else if input.createTextRange
            range = input.createTextRange()
            range.collapse(true)
            range.moveEnd('character', position)
            range.moveStart('character', position)
            range.select()

    @AdjustCaretForReverseMask: (source) ->
        source.keyup (e) ->
            if e.which is 8
                caretPosition = Helpers.Client.DOM.GetCaretPosition(@)

                if caretPosition > 0
                    Helpers.Client.DOM.SetCaretPosition(@, caretPosition - 1)

    @ScrollTo: (target) =>
        finalY = target.offset().top - 50
        finalY = 0 if finalY < 0

        $('html, body').animate({
            scrollTop: finalY
        }, 500);

    @ScrollTop: (target) =>
        $('html, body').animate({
            scrollTop: 0
        }, 500);

    @MenuScroller: (source, affixTarget, target) =>
        source.find('a.scroll-to').click (e) ->
            e.preventDefault();
            $current = $ @
            target = $($current.attr('href'))
            DOM.ScrollTo target

        if not IsMobile

            @UntilVisible source, =>
                if affixTarget
                    affixTarget = source.find affixTarget
                    affixTarget.affix {
                        offset:
                            top: source.offset().top - 15,
                            bottom: 100
                    }
                    affixTarget.css {
                        width: affixTarget.width()
                    }

                if target
                    $('body').scrollspy {
                        target: target
                    }

    @UntilVisible: (source, callback) ->

        checkVisible = ->
            if source.is ':visible'
                callback()
                return true
            else
                window.setTimeout checkVisible, 250

        checkVisible()

    @SetUIHooks: (properties) ->
        properties.container.get(0)._uihooks = {
            insertElement: (node, before) ->
                $(node).insertBefore(before)

                if properties.removeTmpHiddenElements
                    properties.container.find('.tmp-hidden').removeClass('tmp-hidden hide')

            removeElement: (node) ->
                $(node).remove()

                if properties.removeTmpHiddenElements
                    properties.container.find('.tmp-hidden').removeClass('tmp-hidden hide')
        }

    @EnableShowHide: (container) ->
        moretext = translate 'commons.show.more'
        lesstext = translate 'commons.show.less'

        container.each ->
            $subcontainer = $ @
            $subcontainer.find('.show-more').each ->
                $link = $ @

                if not $link.data('ready')
                    $link.click (e) ->
                        e.preventDefault()
                        e.stopPropagation()
                        $this = $ @

                        if $subcontainer.find($this.data('target')).hasClass('in')
                            $subcontainer.find('.show-more-text').text(moretext)
                            $subcontainer.find($this.data('target')).slideUp(250).removeClass('in');
                        else
                            $subcontainer.find('.show-more-text').text(lesstext)
                            $subcontainer.find($this.data('target')).slideDown(250).addClass('in');

                    $link.data('ready', true)

    @AutoShort: (originalText, container, maxLength, toHtml) -> # we need the originalText as 'container' text may be in HTML and we don't want to date to substring that
        ellipsestext = "..."
        moretext = translate 'commons.show.more'
        lesstext = translate 'commons.show.less'

        container.each ->

            $this = $ @

            content = originalText

            if content.length > maxLength
                c = originalText.substr 0, maxLength
                h = originalText.substr maxLength, content.length - maxLength
                if toHtml
                    c = c.toHTMLFormat()
                    h = h.toHTMLFormat()

                html = c + '<span class="moreellipses">' + ellipsestext+ '&nbsp;</span><span class="morecontent"><span>' + h + '</span>&nbsp;&nbsp;<a href="" class="morelink">' + moretext + '</a></span>'

                $this.html html

            $this.find('.morelink').click (e) ->
                $this = $ @
                if $this.hasClass 'less@2.5.0_2'
                    $this.removeClass 'less@2.5.0_2'
                    $this.html moretext
                else
                    $this.addClass 'less@2.5.0_2'
                    $this.html lesstext

                $this.parent().prev().toggle()
                $this.prev().toggle()
                e.preventDefault()

    @InitTooltips: =>
        $('.with-tooltip').not('.tooltip-initialized').each(->
            $this = $ @

            title = $this.attr('title')

            if title
                $this.addClass('.tooltip-initialized').tooltip()
        )
