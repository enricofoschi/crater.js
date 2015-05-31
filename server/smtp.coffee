Meteor.startup =>
    Meteor.Mailgun.config {
        username: Meteor.settings.mailgun.username
        password: Meteor.settings.mailgun.password
    }