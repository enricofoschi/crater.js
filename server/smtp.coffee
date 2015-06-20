Meteor.startup =>
    Meteor.Sendgrid.config {
        username: Meteor.settings.sendgrid.username
        password: Meteor.settings.sendgrid.password
    }