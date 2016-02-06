DATA_KEY = 'data-timeproposals'

_getData = (instance) ->
    instance.changeTracker.depend()
    return $(instance.firstNode).data(DATA_KEY) || []

_setData = (instance, value) ->

    value ||= []

    value = value.filter((item) -> (item.available_for || []).length > 0)

    value = _.sortBy(value, (item) -> item.date)
    $(instance.firstNode).data(DATA_KEY, value)
    instance.changeTracker.changed()

Helpers.Client.TemplatesHelper.Handle('afDatetimeProposalsPicker', (template) =>

    '''Expected data format:
    [{
        date: new Date()
        minutes: 60
        available_for: ['asdsadsd21']
    }]
    '''

    _editMode = new ReactiveVar()


    template.onCustomCreated = ->
        @changeTracker = new Tracker.Dependency
        _editMode.set(false)

    template.helpers({

        isReadonly: ->
            return @atts?.readonly is ''

        isSelected: ->
            return Meteor.userId() in (@available_for || [])

        editMode: ->
            return _editMode.get()

        slots: ->
            instance = Template.instance()

            slots = _getData(instance) || instance.data.value

            slots.forEach((slot) ->
                slot.startDate = moment(slot.date).format('ddd DD MMM YYYY')
                slot.startTime = moment(slot.date).format('HH:mm')
                slot.endTime = moment(slot.date.addSeconds(slot.minutes * 60)).format('HH:mm')
                slot.selected = slot.selected
            )

            slotsByDay = _.groupBy(slots, (slot) ->
                return moment(slot.date).format('ddd DD MMM YYYY')
            )

            slotsByDayList = _.map(slotsByDay, (list, day) ->
                {
                    day: day
                    list: list
                }
            )

            return slotsByDayList.toMatrix(3)

        canRemove: ->
            return Meteor.userId() in @available_for and @available_for.length is 1

    })

    template.events({
        'click .slot': (e, instance) ->
            slots = _getData(instance)

            slot = slots.find((slot) => slot.date is @date and slot.minutes is @minutes)

            slot.available_for = (slot.available_for || []).filter((id) -> id isnt Meteor.userId())

            _setData(instance, slots)

        'click .btn-add-new-proposal': ->
            _editMode.set(true)

        'click .btn-add-proposal': (e, instance) ->
            date = Helpers.Client.Form.GetDatePickerValue(instance.$('.datepicker-container'))

            slots = _getData(instance)
            slots.push({
                date: date
                minutes: parseInt(instance.find('.txt-duration').value) || 60
                selected: true
                available_for: [Meteor.userId()]
            })
            _setData(instance, slots)
            _editMode.set(false)
    })

, ->
    _setData(@, @data.value)
    _currentInstance = @

    Helpers.Client.Form.LoadDatePicker(=>
        Helpers.Client.Form.InitDatePicker({
            target: _currentInstance.$('.datepicker-container')
            minDate: (new Date())
            maxDate: (new Date()).addDays(180)
            dateFormat: ServerSettings.dateFormat + ' HH:mm'
        })
    )
)

Crater.startup(->
    AutoForm.addInputType('dateTimeProposalsPicker', {
        template: 'afDatetimeProposalsPicker'
        valueIn: (val) ->
            return val
        valueOut: ->
            return @data(DATA_KEY)
    })
)