Crater.startup =>
    if Meteor.settings.sendgrid
        Meteor.Sendgrid.config {
            username: Meteor.settings.sendgrid.username
            password: Meteor.settings.sendgrid.password
        }