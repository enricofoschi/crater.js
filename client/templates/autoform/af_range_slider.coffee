Helpers.Client.TemplatesHelper.Handle('af_range_slider', (template) =>
    template.helpers {
        schemaKey: ->
            @atts['data-schema-key']
        attsSkimmed: ->
            r = _.extend {}, @atts
            delete r.sliderOptions
            r
    }
, ->

    minMax = @data.value.split(',')
    start = parseInt(minMax[0])
    end = parseInt(minMax[1])

    options = @data.atts.sliderOptions

    if options.start and not start
        start = options.start

    if options.end and not end
        end = options.end

    if options.innerRange and not start
        start = options.innerRange[0]
        end = options.innerRange[1]

    if start < options.min
        end = options.min + 10000

    sliderComponent = @$('.slider:first').get(0)
    sliderInput = @$('input:first').get(0)
    sliderInput.value = options.min + ',' + options.max

    noUiSlider.create sliderComponent, {
        start: [start, end]
        connect: true
        step: options.step
        behaviour: 'drag'
        range:
            min: options.min,
            max: options.max
    }

    if options.innerRange
        sliderComponent.noUiSlider.on 'slide', (values, handle) ->
            if values[0] < options.innerRange[0]
                sliderComponent.noUiSlider.set options.innerRange[0]

            if values[1] < options.innerRange[0]
                sliderComponent.noUiSlider.set [values[0], options.innerRange[0]]

    tipHandles = sliderComponent.getElementsByClassName('noUi-handle')
    tooltips = []

    for tipHandle in tipHandles
        newDiv = document.createElement('div');
        newDiv.className = 'noUi-tooltip'
        newDiv.innerHTML = '<span></span>'
        tipHandle.appendChild newDiv
        newDiv = newDiv.getElementsByTagName('span')[0]
        tooltips.push newDiv

    _onUpdate = options.onUpdate
    options.onUpdate = (values, handle) ->
        val = parseInt(values[handle])
        isMax = val is options.max
        val = Math.round((parseInt(values[handle]) / 1000))
        val += '+' if isMax
        val += 'k' if options.extraK

        if _onUpdate
            _onUpdate.apply @, arguments

        return val

    sliderComponent.noUiSlider.on 'update', (values, handle) ->
        tooltips[handle].innerHTML = options.onUpdate values, handle
        sliderInput.value = parseInt(values[0]) + ',' + parseInt(values[1])
)

Crater.startup ->
    AutoForm.addInputType 'rangeSlider', {
        template: 'af_range_slider'
        valueIn: (val) ->
            val
    }