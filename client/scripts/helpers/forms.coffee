class @Helpers.Client.Form

    @ClearInputs: (form) ->
        form.get(0).reset()
        $(input).trigger('checkval') for input in form.find('input,textarea,select').not('[type="hidden"]')

    @GetFormHooks: (options) ->

        options = _.extend {
            withLoader: true
        }, options

        _before = _.extend {}, options.before || {}
        _beforeInsert = _before.insert
        _beginSubmit = options.beginSubmit
        _formToDoc = options.formToDoc

        newOptions = {
            formToDoc: (doc, schema) ->
                if _formToDoc
                    doc = _formToDoc.apply(@, arguments)

                if ServerSettings.debug
                    try
                        check doc, schema
                    catch e
                        Helpers.Log.Warning e

                return doc

            beginSubmit: ->
                Helpers.Client.Loader.Show() if options.withLoader
                _beginSubmit.apply(@, arguments) if _beginSubmit
            endSubmit: ->
                Helpers.Client.Loader.Hide() if options.withLoader
            before: _.extend(_before, {
                insert: (attr) ->
                    attr.createdAt ||= (new Date()).UTCFromLocal()
                    attr.updatedAt = attr.createdAt

                    if _beforeInsert
                        return _beforeInsert(attr)
                    else
                        return attr
            })
        }

        _.extend options, newOptions

    @ShowGeneralError: =>
        if ServerSettings?.debug
            console.log arguments

        Helpers.Client.Notifications.Error translate('commons.error.form_submit')

    @RunOnChange: (identifier, container, callback) =>
        runOnChangeClass = 'run-on-change-init-' + identifier

        # input fields
        container.find('input[type="text"],textarea').not('.no-auto-tracking').not('.' + runOnChangeClass).addClass(runOnChangeClass).blur(->
            Helpers.Log.Info 'Blur on ' + $(@).attr('class')
            callback.apply @, arguments
        ).keypress((e) ->
            if @tagName?.toLowerCase() isnt 'textarea' and e.which is 13
                @blur()
        )


        # selects
        container.find('select').not('.' + runOnChangeClass).addClass(runOnChangeClass).change ->
            Helpers.Log.Info 'New value on DDL' + $(@).attr('class')
            callback.apply @, arguments

        # checkboxes
        container.find('input[type="checkbox"]').not('.' + runOnChangeClass).addClass(runOnChangeClass).change ->
            Helpers.Log.Info 'Check on ' + $(@).attr('class')
            callback.apply @, arguments

        datepickers = container.find('.datepicker').not('.' + runOnChangeClass).addClass(runOnChangeClass)

        if not IsMobile
            # date pickers

            datepickers.each ->
                $this = $ @
                currentDatepicker = $this.datepicker()

                # Triggering the change event only if the datepicker has been opened
                currentDatepicker.on('show', ->
                    $this.data('can-trigger-datepicker-change', true)
                )

                currentDatepicker.on('changeDate', ->
                    if $this.data('can-trigger-datepicker-change')
                        $this.data('can-trigger-datepicker-change', false)
                        Helpers.Log.Info 'Change data ' + $this.attr('class') + ' to ' + $this.datepicker('getUTCDate')
                        callback.apply @, arguments
                )
        else

    @LimitFromToFields: (yearFrom, yearTo, monthFrom, monthTo) ->
        hideOptionsLowerThan = (number, select) ->
            select.find('option').each ->
                currentValue = parseInt(@value)
                if currentValue and currentValue < number
                    $(@).hide()
                else
                    $(@).show()

        limit = ->
            yearFromValue   = parseInt(yearFrom.val())
            monthFromValue  = parseInt(monthFrom.val())
            yearToValue     = parseInt(yearTo.val())
            monthToValue    = parseInt(monthTo.val())

            if yearToValue < yearFromValue
                yearTo.val(yearFromValue)
                yearToValue = yearFromValue

            if yearToValue is yearFromValue
                if monthToValue < monthFromValue
                    monthTo.val(monthFromValue)

                hideOptionsLowerThan(monthFromValue, monthTo)
            else
                hideOptionsLowerThan(0, monthTo)

            hideOptionsLowerThan(yearFromValue, yearTo)

        limit()

        yearFrom.change limit
        monthFrom.change limit
        yearTo.change limit
        monthTo.change limit

    @DisableOnChecked: (checkbox, target) ->
        disableTarget = ->
            if not checkbox.get(0)
                return
            if checkbox.get(0).checked
                target.find('select,input,textarea').each ->
                    $this = $ @
                    $this.addClass 'disabled'
                    $this.data 'pre-disabled-value', $this.val()
                    @disabled = true
                    $this.val('')
            else
                target.find('select,input,textarea').each ->
                    $this = $ @
                    $this.removeClass 'disabled'
                    @disabled = false
                    prevValue = $this.data 'pre-disabled-value'

                    if prevValue
                        $this.val()

        disableTarget()

        checkbox.change disableTarget

    @AddChangeEventToTemplateSelector: (properties) ->

        events = {}

        if properties.type is 'dropdown'
            events['change ' + properties.selector] = (e) ->
                # ensuring we don't trigger twice
                $this = $ e.target

                if $this.data('last-change-trigger-ts') isnt e.timeStamp
                    $this.data 'last-change-trigger-ts', e.timeStamp
                    properties.callback.apply @, arguments
        else
            if properties.type isnt 'textarea'
                events['keypress ' + properties.selector] =  (e) ->
                    if e.which is 13
                        e.target.blur()

            events['blur ' + properties.selector] =  (e) ->

                originalValue = e.target.value

                result = properties.callback.apply @, arguments

                if result
                    if originalValue
                        if properties.reset
                            e.target.value = ''

                        if properties.refocus
                            e.target.focus()

            if properties.keyPress
                delayedTrigger = null
                events['keypress ' + properties.selector] =  (e) ->
                    if delayedTrigger
                        window.clearTimeout(delayedTrigger)

                    event = @
                    args = arguments
                    delayedTrigger = window.setTimeout =>
                        properties.callback.apply event, args
                    , 250


        properties.template.events events

    @InitTypeAhead: (properties) ->
        if not properties.noEnterKeyHandling
            Helpers.Client.DOM.OnEnterKey properties.source, (e) ->

                $this = $ @

                # Don't do anything if a current selection on typeahead is enabled
                if $this.siblings('.typeahead.dropdown-menu:visible').find('li.active:visible').length and e.which is 13
                    return

                if properties.saveCallback
                    properties.saveCallback.call @
            , false, true, false

        properties.source.typeahead {
            source: properties.data
            autoSelect: false
            afterSelect: (item) ->
                if properties.saveCallback
                    properties.saveCallback.call properties.source.get(0)
                    properties.source.val('').get(0).focus()
        }

    @LoadDatePicker: (callback) ->
        Helpers.Client.DOM.LoadJS {
            identifier: 'datepickerjs'
            url: ServerSettings.urls.js + 'datepicker.js'
            callback: callback
            onLoad: ->
                Helpers.Client.DOM.LoadCSS ServerSettings.urls.css + 'datepicker.css'
            blockUI: true
        }

    @Destroy: (instance) ->
        instance.$('.datepicker-container').each(->
            dp = $(@).data("DateTimePicker")

            if dp
                dp.destroy()
        )

    @InitDatePicker: (properties) ->

        if not IsMobile
            minDate = properties.minDate || new Date()
            minDate.setHours(0)
            minDate.setMinutes(0)

            if not defaultDate = properties.value
                defaultDate = new Date()
                defaultDate.setHours(0)
                defaultDate.setMinutes(0)

                if defaultDate < minDate
                    defaultDate = minDate

            properties.target.datetimepicker {
                stepping: 15
                minDate: minDate
                maxDate: properties.maxDate || (new Date).addDays(15)
                locale: Helpers.Translation.GetUserLanguage()
                defaultDate: defaultDate
                format: ServerSettings.dateFormat
                icons:
                    time: 'fa fa-time'
                    date: 'fa fa-calendar'
                    up: 'fa fa-chevron-up'
                    down: 'fa fa-chevron-down'
                    previous: 'fa fa-chevron-left'
                    next: 'fa fa-chevron-right'
                    today: 'fa fa-screenshot'
                    clear: 'fa fa-trash',
                    close: 'fa fa-remove'
                sideBySide: true
            }


            properties.target.find('input').focus ->
                $(@).parents('.datepicker-container:first').data('DateTimePicker').show()
        else
            $input = properties.target.find('input')

            if properties.noTime
                $input.attr('type', 'date')
            else
                $input.attr('type', 'datetime-local')

            $input.siblings('.input-group-addon').click ->
                $(@).siblings('input').focus()

            if properties.value
                $input.val(moment(properties.value).format('YYYY-MM-DD'))

    @GetDatePickerValue: (container) ->

        $container = $(container)
        $input = $container.find('input:first')

        if not IsMobile
            date = $container.data('DateTimePicker').date()

            if date
                return date.toDate()
            else
                return null
        else
            if $input.val()
                date = moment($input.val()).toDate()
                return date
            else
                return null

    @InitCropper: (callback) ->

        prefix = ServerSettings.urls.cdn + 'components/cropper/'

        Helpers.Client.DOM.LoadCSS prefix + 'cropper.min.css'
        Helpers.Client.DOM.LoadJS {
            blockUI: true
            identifier: 'jquery-cropper'
            url: prefix + 'cropper.min.js'
            callback: callback
        }



# Initialising required translation
Meteor.startup ->
    Helpers.Translation.OnCommonTranslationsLoaded ->
        translate('commons.error.form_submit')
