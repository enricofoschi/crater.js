Meteor.publish 'admin_users', ->
    if Roles.userIsInRole @userId, ['admin']
        Meteor.users.find {}
    else
        Meteor.users.find {
            _id: 0
        }


Meteor.publish 'available_users', ->
        if not @userId
            Meteor.users.find {
                _id: '-'
            }
        else

            if @userId
                user = new MeteorUser @userId
                user.ensureMain()

            fields = Crater.Users.Server.PublicationHelpers.GetPublicationFields.call @, @userId
            fields.all_fields = 1 # required to ensure we refresh the proper user

            Meteor.users.find {
                _id: @userId
            }, {
                fields: fields
            }

Meteor.publish 'reset_password_user', (id, token) ->

    Meteor.users.find {
        _id: id
        password_reset_token: token
    }, {
        fields:
            _id: 1
            password_reset_token: 1
            first_name: 1
            last_name: 1
            full_name: 1
    }
