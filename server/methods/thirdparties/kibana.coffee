Meteor.methods {
    'kibana.rebuild': (full)->

        if not Roles.userIsInRole(Meteor.userId(), 'admin')
            throw 'Nope'

        kibanaServices = Crater.Services.Get Services.KIBANA
        kibanaServices.rebuild(full)
}
