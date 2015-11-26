globalContext = @

class @Crater.Services.Core.StateMachine extends @Crater.Services.Core.Base

    runChecks: =>
        start = new Date()

        # Going through all state machines
        for classDef in StateMachineDriven

            entities = classDef.find({}, {
                status: 1
                history: 1
            }).fetch()

            # Going through all types of state machine configs
            for own key, config of classDef.stateMachineConfig

                # Going through all automated behavior configurations
                for autoBehavior in (config.auto || [])

                    # Filtering by records in this status
                    records = _.filter entities.clone(), (e) -> e.status in autoBehavior.statuses

                    # Going through each records
                    for record in records
                        try
                            sm = record.getStateMachine()
                            lastUpdate = sm.getLastUpdateDate()
                            nextAction = null

                            # Finding next action
                            for action, index in autoBehavior.actions
                                autoHistory = sm.getAutoHistoryId(action.id)

                                # This action was already taken
                                if autoHistory
                                    lastUpdate = autoHistory.date
                                # This action has still to be taken
                                else
                                    skip = action.filterBy(record) if action.filterBy
                                    continue if skip

                                    # If the time expiration is gone
                                    expiration = lastUpdate.addDays action.wait

                                    if (new Date()) - expiration > 0
                                        nextAction = action
                                    break

                            if nextAction
                                @performAction nextAction, classDef.first record._id
                        catch e
                            console.error e
                            throw e if ServerSettings.debug


        end = new Date()
        console.log 'State machine time (s):', (end - start) / 1000

    performAction: (action, instance) =>

        stateMachine = instance.getStateMachine()

        if action.type is globalContext.StateMachine.ACTION_TYPE.EMAIL
            @sendEmail action, stateMachine, instance, action.getReceiver(instance), action.template, action.untranslated
        else if action.type is globalContext.StateMachine.ACTION_TYPE.EMAILS
            for email in action.emails
                @sendEmail action, stateMachine, instance, email.getReceiver(instance), email.template, email.untranslated

    sendEmail: (action, stateMachine, instance, toUser, template, untranslated) =>
        logService = Crater.Services.Get Services.LOG
        emailDataAr = instance.toEmailDataForMandrill(toUser)

        # Failsafe
        identifier = 'entity_id_' + instance._id + '_' + action.id + '_' + toUser._id
        alreadySent = Crater.Collections.Email.first {
            to: toUser.email
            'data.message.global_merge_vars.content': identifier
        }

        if alreadySent
            logService.Error 'Email already sent. Preventing another one from being sent', identifier, toUser.email
        else
            logService.Info 'Sending statemachine reminder', identifier, toUser.email
            if Meteor.settings.local
                console.log 'No - local'
            else
                emailService = Crater.Services.Get Services.EMAIL
                emailService.SendWithMandrill template, {
                    toUser: toUser
                    untranslated: untranslated
                    global_merge_vars: [
                        {
                            name: 'identifier'
                            content: identifier
                        }
                    ].concat(emailDataAr)
                }, toUser.email

        stateMachine.addAutoHistory action