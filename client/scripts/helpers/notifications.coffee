class @Helpers.Client.Notifications

    @Success: (msg, title = 'Success') ->
        sweetAlert title, msg, "success"

    @Error: (msg, title = 'Damn') ->
        sweetAlert title, msg, "error"

    @Confirm: (msg, callback) ->
        sweetAlert {
            title: "Are you sure?"
            text: msg
            type: "warning"
            showCancelButton: true
            confirmButtonColor: "#DD6B55"
            confirmButtonText: "Yes"
            closeOnConfirm: true
        }, callback