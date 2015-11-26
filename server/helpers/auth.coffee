class @Helpers.Server.Auth

    @GetCurrentConnection: ->
        if @connection
            @connection
        else
            DDP._CurrentInvocation?.get()?.connection

    @GetCurrentConnectionId: ->
        if @connection
            @connection.id
        else
            DDP._CurrentInvocation?.get()?.connection?.id