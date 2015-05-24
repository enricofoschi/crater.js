Meteor.startup( =>
    if Meteor.settings.smtp?.username
        process.env.MAIL_URL = "smtp://#{Meteor.settings.smtp.username}:#{Meteor.settings.smtp.password}@#{Meteor.settings.smtp.server}/"
)