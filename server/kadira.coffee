if Meteor.settings.kadiraAuth?.appId and Meteor.settings.kadiraAuth.on
    Kadira.connect Meteor.settings.kadiraAuth.appId, Meteor.settings.kadiraAuth.appSecret