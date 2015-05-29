class @Helpers.Client.Notifications

    @Success: (msg, title = 'Success') ->
        sweetAlert title, msg, "success"

    @Error: (msg, title = 'Damn') ->
        sweetAlert title, msg, "error"