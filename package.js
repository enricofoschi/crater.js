Package.describe({
  name: 'enricofoschi:crater.js',
  version: '0.0.9',
  // Brief, one-line summary of the package.
  summary: 'Meteor Micro Framework For Highly Effective Projects',
  // URL to the Git repository containing the source code for this package.
  git: 'https://github.com/enricofoschi/crater.js',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.1.0.2');
	api.use([
		'iron:router@1.0.9',
		'underscore@1.0.3',
		'reactive-var@1.0.5',
		'meteorhacks:kadira@2.21.0',
		'coffeescript@1.0.6',
		'kaptron:minimongoid@0.9.5',
		'aldeed:collection2@2.3.3',
		'aldeed:autoform@5.3.0',
		'aldeed:tabular@1.2.0',
		'yogiben:autoform-modals@0.3.5',
		'meteor-platform@1.2.2',
		'accounts-base@1.2.0',
		'useraccounts:bootstrap@1.10.0',
		'accounts-ui@1.1.5',
		'alanning:roles@1.2.13',
		'aldeed:tabular@1.2.0',
		'service-configuration@1.0.4',
		'meteorhacks:npm@1.3.0'
	]);

	api.use([
		'fortawesome:fontawesome@4.3.0',
		'less@1.0.14',
		'twbs:bootstrap@3.3.4'
	], 'client');

	api.use([
		'email@1.0.6',
		'http@1.1.0',
		'gfk:mailgun-api@1.1.0',
		'cunneen:mailgun@0.9.1',
		'meteorhacks:ssr@2.1.2',
		'meteorhacks:async@1.0.0',
		'base64@1.0.3'
	], 'server');

	api.addFiles([
		'lib/_base/_base.coffee',
		'lib/components/datatables.coffee',
		'lib/extensions/array.coffee',
		'lib/extensions/date.coffee',
		'lib/extensions/strings.coffee',
		'lib/helpers/_core/core.coffee',
		'lib/helpers/common/conversions.coffee',
		'lib/helpers/common/token.coffee',
		'lib/helpers/application.js',
		'lib/environment.js',
		'lib/router.coffee',
		'collections/_base/_base.coffee',
		'collections/_base/basecollection.coffee',
		'collections/time/_base.coffee',
		'collections/currentusersession.coffee',
		'collections/meteoruser.coffee'
	]);

	api.addFiles([
        'client/scripts/helpers/auth.coffee',
		'client/scripts/helpers/forms.coffee',
		'client/scripts/helpers/loader.coffee',
		'client/scripts/helpers/meteor.coffee',
		'client/scripts/helpers/notifications.coffee',
		'client/scripts/helpers/session.coffee',
		'client/scripts/helpers/storage.coffee',
		'client/scripts/helpers/template.coffee',
		'client/scripts/lib/amplify.js',
		'client/scripts/lib/sweetalert.min.js',
		'client/scripts/lib/bootbox.min.js',
		'client/scripts/loaders/adaptive-label.js',
		'client/scripts/start.coffee',
        'client/styles/lib/datatables.fixes.css',
		'client/styles/lib/sweetalert.css',
	], 'client');

	api.addFiles([
		'server/api/_base/_base.coffee',
		'server/api/_base/basic_auth.coffee',
		'server/api/_base/oauth1.coffee',
		'server/api/_base/oauth2.coffee',
		'server/api/Google/_base.coffee',
		'server/api/Google/calendar.coffee',
		'server/api/Xing/_base.coffee',
		'server/api/Xing/authentication.coffee',
        'server/api/LinkedIn/_base.coffee',
        'server/api/LinkedIn/profile.coffee',
		'server/fixtures/_base.coffee',
		'server/fixtures/user.coffee',
		'server/helpers/auth.coffee',
		'server/helpers/communication.coffee',
		'server/helpers/email.coffee',
		'server/helpers/session.coffee',
		'server/helpers/time.coffee',
		'server/methods/auth/session.coffee',
        'server/methods/thirdparties/xing.coffee',
        'server/methods/thirdparties/linkedin.coffee',
		'server/services/_base/_base.coffee',
		'server/services/core/_base.coffee',
		'server/services/core/log.coffee',
		'server/services/thirdparties/_base.coffee',
		'server/services/thirdparties/xing.coffee',
        'server/services/thirdparties/linkedin.coffee',
		'server/services/config.coffee',
		'server/publications/roles.coffee',
		'server/kadira.coffee',
		'server/smtp.coffee',
        'server/users.coffee'
	], 'server');

	Npm.depends({
		"oauth-signature": "1.3.0"
	});
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('enricofoschi:crater.js');
  api.addFiles('crater.js-tests.js');
});
