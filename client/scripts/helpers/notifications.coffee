class @Helpers.Client.Notifications

    @Success: (msg, title = 'Success') ->
        swal title, msg, "success"

    @Error: (msg, title = 'Damn') ->
        swal title, msg, "error"

    @Confirm: (msg, callback) ->

        originalCallback = callback

        callback = ->
            window.setTimeout originalCallback, 300

        swal {
            title: "Are you sure?"
            text: msg
            type: "warning"
            showCancelButton: true
            confirmButtonColor: "#DD6B55"
            confirmButtonText: "Yes"
            closeOnConfirm: true
        }, callback

    @Prompt: (msg, callback) ->
        bootbox.prompt msg, (result) ->
            if result
                callback result