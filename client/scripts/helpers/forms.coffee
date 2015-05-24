class @Helpers.Client.Form

    @ClearInputs: (form) ->
        form.get(0).reset()
        $(input).trigger('checkval') for input in form.find('input,textarea,select').not('[type="hidden"]')

    @GetFormHooks: (options) ->
        _.extend options, {
            before: {
                insert: (attr) ->
                    attr.createdAt ||= (new Date()).UTCFromLocal()
                    attr.updatedAt = attr.createdAt

                    attr
            }
        }