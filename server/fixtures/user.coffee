Global = @

class @Fixture.Users extends Fixture.Base

    @_collection: Meteor.users

    @_uniqueFilter: (u) ->
        {
        emails:
            $elemMatch:
                address: u.email
        }

    @_data: _.map Meteor.settings.users, (u) ->
        {
        email: u.email
        password: u.password
        profile:
            firstName: u.firstName
            lastName: u.lastName
        }

    @_getUser: (attr) ->
        _.find Meteor.settings.users, (u) ->
            u.email is attr.email

    @_create: (attr) ->
        id = Accounts.createUser attr

        dataUser = @_getUser attr

        if dataUser.roles
            Roles.addUsersToRoles id, dataUser.roles