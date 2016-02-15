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
        return _.find(@config.statuses, (s) => s.name is @obj[@config.field])

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
       return @getAutoHistory().find((h) -> h.id is id)

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

        getAutoActionId: (action, status) =>
            actionId = action.id

            if action.repeatOnLoop
                actionId = actionId += '_' + @getStatusOccurrencesCount(status)

            return actionId

        addAutoHistory: (action, status) =>
            history = {}

            actionId = @getAutoActionId(action, status)

            history['history.auto.' + @config.field] = {
                date: new Date()
                id: actionId
            }

            @obj.addToSet history

        getStatusOccurrencesCount: (status) =>
            return (@obj.history?[@config.field] || []).filter((statusHistory) -> statusHistory.status is status).length

        removeAllAutoActionsForStatus: (status) =>

            if @obj.history?.auto?[@config.field]

                idsForStatus = _.pluck(@config.auto.find((autoStatus) -> autoStatus.statuses.length is 1 and autoStatus.statuses[0] is status)?.actions || [], 'id')
                console.log(idsForStatus)



                @obj.history.auto[@config.field] = @obj.history.auto[@config.field].filter((auto) ->
                    return auto.id not in idsForStatus
                )

                @obj.update({
                    history: @obj.history
                })

        updateStatus: (status) =>

            statusConfig = @getCurrentStatusConfig()

            if not (status in (statusConfig.next || []))
                @_logService.Error 'Cannot update', @config.field, @obj[@config.field], status, statusConfig, @obj._id
                throw Error('Cannot update')

            @addHistory(status)

            updateObj = {}
            updateObj[@config.field] = status
            errors = @obj.update(updateObj).errors
            if not errors
                statusConfig = @getCurrentStatusConfig()
                if statusConfig.actions
                    for action in statusConfig.actions
                        action.action @obj
            else
                console.error(errors)
                throw Error(errors)

        undo: =>

            history = @obj.history[@config.field]

            if history and history.length > 1 and history[history.length - 1].status is @getStatus()
                history.pop()
                updateObj = {
                    history: {}
                    status: history[history.length - 1].status
                }
                updateObj.history[@config.field] = history
                @obj.update(updateObj)



