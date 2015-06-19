class @Helpers.Client.Form

    @ClearInputs: (form) ->
        form.get(0).reset()
        $(input).trigger('checkval') for input in form.find('input,textarea,select').not('[type="hidden"]')

    @GetFormHooks: (options) ->

        origBefore = _.extend {}, options.before

        _.extend options, {
            beginSubmit: ->
                Helpers.Client.Loader.Show()
            endSubmit: ->
                Helpers.Client.Loader.Hide()
            before: _.extend options.before, {
                insert: (attr) ->
                    attr.createdAt ||= (new Date()).UTCFromLocal()
                    attr.updatedAt = attr.createdAt

                    if origBefore.insert then origBefore.insert(attr) else attr
            }
        }