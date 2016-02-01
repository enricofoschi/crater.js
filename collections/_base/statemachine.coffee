global = @

class @StateMachine

    _logService: null

    @ACTION_TYPE: {
        EMAIL: 'email'
        EMAILS: 'emails'
        DO_STUFF: 'do_stuff'
    }

    constructor: (@config, @obj) ->
        if Meteor.isServer
            @_logService = Crater.Services.Get Services.LOG

    # Getters
    getStatus: =>
        @obj[@config.field]

    getStatuses: =>

        ar = []
        for own key, value of @config.statuses
            ar.push {
                status: key
                val: value.name
                current: @getStatus() is value.name
            }

        ar

    getCurrentStatusConfig: =>
        status = _.find @config.statuses, (s) => s.name is @obj[@config.field]

    canMoveTo: (status) =>
        status in (@getCurrentStatusConfig()?.next || [])

    getStatusDate: (status) =>
        status = _.find @obj.history[@config.field], (s) -> s.status is status
        status?.date

    getStatusHistory: =>
        _.map @obj.history[@config.field], (s) ->
            s.status

    getLastUpdateDate: =>
        @getLastUpdate()?.date

    getLastUpdate: =>
        history = @obj.history?[@config.field]

        if history and history.length
            return history[history.length - 1]
        else
            return null

    getAvailableActions: =>
        @getCurrentStatusConfig().next || []

    getHistory: =>
        @obj.history?[@config.field]?.cloneWithObjects() || []

    getAutoHistory: =>
        @obj.history?.auto?[@config.field] || []

    getAutoHistoryId: (id) =>
        _.find @getAutoHistory(), (h) -> h.id is id

if Meteor.isServer

    class @StateMachine extends StateMachine
        # Updating
        initStatus: =>
            @addHistory @obj[@config.field]

        addHistory: (status, date, userId) =>
            history = {}

            history['history.' + @config.field] = {
                status: status
                date: date || new Date()
                user_id: userId || Meteor.userId()
            }

            @obj.addToSet history

        addAutoHistory: (action) =>
            history = {}

            history['history.auto.' + @config.field] = {
                date: new Date()
                id: action.id
            }

            @obj.addToSet history

        updateStatus: (status) =>

            statusConfig = @getCurrentStatusConfig()

            if not (status in (statusConfig.next || []))
                @_logService.Error 'Cannot update', status, statusConfig
                throw 'Cannot update'

            @addHistory status

            updateObj = {}
            updateObj[@config.field] = status
            if not @obj.update(updateObj).errors
                statusConfig = @getCurrentStatusConfig()
                if statusConfig.actions
                    for action in statusConfig.actions
                        action.action @obj

        undo: =>

            history = @obj.history[@config.field]

            if history and history.length > 1 and history[history.length - 1].status is @getStatus()
                history.pop()
                updateObj = {
                    history: {}
                    status: history[history.length - 1].status
                }
                updateObj.history[@config.field] = history
                @obj.update updateObj



