Package.describe({
  name: 'enricofoschi:crater.js',
  version: '0.0.1',
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
		'meteor-platform@1.2.2',
		'iron:router@1.0.7',
		'underscore@1.0.3',
		'houston:admin@2.0.3',
		'reactive-var@1.0.5',
		'meteorhacks:kadira@2.21.0',
		'coffeescript@1.0.6',
		'kaptron:minimongoid@0.9.5',
		'aldeed:collection2@2.3.3',
		'aldeed:autoform@5.2.0',
		'aldeed:tabular@1.2.0',
		'minimongo@1.0.8',
		'mongo-livedata@1.0.8',
		'templating@1.1.1'
	]);


	api.use([
		'fortawesome:fontawesome@4.3.0',
		'francocatena:compass@0.5.1',
		'kevohagan:sweetalert@0.5.0',
		'fourseven:scss@3.1.1'
	], 'client');

	api.use([
		'email@1.0.6',
		'http@1.1.0',
		'gfk:mailgun-api@1.1.0',
		'meteorhacks:ssr@2.1.2',
		'meteorhacks:async@1.0.0'
	], 'server');

	api.addFiles([
		'client/scripts/helpers/auth.coffee',
		'client/scripts/helpers/forms.coffee',
		'client/scripts/helpers/loader.coffee',
		'client/scripts/helpers/meteor.coffee',
		'client/scripts/helpers/session.coffee',
		'client/scripts/helpers/storage.coffee',
		'client/scripts/lib/amplify.js',
		'client/scripts/loaders/adaptive-label.js',
		'client/scripts/start.coffee',
		'collections/base/basecollection.coffee',
		'collections/currentusersession.coffee',
		'lib/components/datatables.coffee',
		'lib/extensions/array.coffee',
		'lib/extensions/date.coffee',
		'lib/extensions/strings.coffee',
		'lib/helpers/_core/core.coffee',
		'lib/helpers/common/conversions.coffee',
		'lib/helpers/common/token.coffee',
		'lib/helpers/application.js',
		'lib/environment.js',
		'private/templates/email/base/foot.template',
		'private/templates/email/base/head.template',
		'private/templates/email/alert.template',
		'server/helpers/auth.coffee',
		'server/helpers/communication.coffee',
		'server/helpers/email.coffee',
		'server/helpers/session.coffee',
		'server/methods/auth/session.coffee',
		'server/kadira.coffee',
		'server/smtp.coffee',
		'scss.json'
	]);
});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('enricofoschi:crater.js');
  api.addFiles('crater.js-tests.js');
});
