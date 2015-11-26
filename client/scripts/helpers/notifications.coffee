class @Helpers.Client.Notifications

    # Pre-set translations
    Meteor.startup ->
        Helpers.Translation.OnCommonTranslationsLoaded ->
            translate("commons.modals.title.success")
            translate("commons.modals.title.warning")
            translate("commons.modals.title.error")

    @Success: (msg, title) ->
        title ||= translate("commons.modals.title.success")

        swal title, msg, "success"

    @Error: (msg, title) ->

        title ||= translate("commons.modals.title.error")

        swal title, msg, "error"

    @Warning: (msg, title, callback) ->

        title ||= translate("commons.modals.title.warning")

        swal {
            title: title
            text: msg
            type: "warning"
        }, callback

    @Confirm: (msg, callbackSuccess, callbackCancel) ->
        callback = (isConfirm) =>
            window.setTimeout =>
                if isConfirm
                    callbackSuccess()
                else
                    callbackCancel()
            , 300

        swal {
            title: translate 'commons.are_you_sure'
            text: msg
            type: "warning"
            showCancelButton: true
            confirmButtonColor: "#DD6B55"
            confirmButtonText: translate 'commons.yes'
            cancelButtonText: translate 'commons.cancel'
            closeOnConfirm: true
            closeOnCancel: true
        }, callback

    @Close: ->
        swal.close()

    @Prompt: (msg, callback, labelConfirm, labelCancel) ->
        bootbox.prompt {
            title: msg
            callback: (result) ->
                if result
                    callback result
            buttons: {
                cancel: {
                    className: 'text-danger right5'
                    label: labelCancel
                }
                confirm: {
                    className: 'btn btn-sm btn-success'
                    label: labelConfirm
                }
            }
        }

    @PromptWithForm: (properties) ->

        randomId = 'form-bootbox-' + Math.round(Math.random() * 1000000)

        getSerializedData = ->
            $form = $('#' + randomId)
            formData = $form.serializeArray()

            formDataSerialized = {}
            for data in formData
                formDataSerialized[data.name] = data.value

            formDataSerialized


        bootbox.dialog {
            message: '<form id="' + randomId + '">' + properties.form.html() + '</form>'
            closeButton: false
            buttons: {
                cancel: {
                    label: properties.cancelLabel ||translate 'commons.cancel'
                    className: 'text-danger right5 ' + (properties.cancelClass || '')
                    callback: ->
                        if properties.closeCallback
                            properties.closeCallback()
                }
                success: {
                    label: properties.successLabel || translate 'commons.send'
                    className: 'btn btn-sm btn-success ' + (properties.successClass || '')
                    callback: ->
                        properties.callback getSerializedData()
                }
            }
        }

        $('#' + randomId).submit (e) ->
            e.preventDefault()

            if properties.onSubmit
                properties.onSubmit(getSerializedData())
            else
                $('.bootbox .btn-success').click()
                false

Crater.startup ->
    bootbox.setLocale Helpers.Translation.GetUserLanguage()