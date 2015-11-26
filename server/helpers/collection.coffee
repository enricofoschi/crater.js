class @Helpers.Collection

    @SubscribeToChange: (cursor, action) =>
        # This is evil and kills performance - even with oplog installed
        cursor.observeChanges {
            added: (id, fields) =>
                try
                    if (new Date()) - fields.createdAt < 500
                        action id, fields, true
                catch e
                    if Meteor.settings.debug
                        throw e
            changed: (id, fields) =>
                try
                    action id, fields, false
                catch e
                    if Meteor.settings.debug
                        throw e
        }
