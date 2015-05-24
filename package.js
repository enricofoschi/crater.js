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
		'meteor-platform',
		'iron:router',
		'underscore',
		'houston:admin',
		'reactive-var',
		'meteorhacks:kadira',
		'coffeescript',
		'kaptron:minimongoid',
		'aldeed:collection2',
		'aldeed:autoform',
		'aldeed:tabular',
		'minimongo',
		'mongo-livedata',
		'templating',
		'meteor-platform'
	]);


	api.use([
		'fortawesome:fontawesome',
		'francocatena:compass',
		'kevohagan:sweetalert',
		'fourseven:scss'
	], 'client');

	api.use([
		'email',
		'gfk:mailgun-api'
	], 'server');

	api.addFiles([
		'client/helpers/auth.coffee',
		'client/helpers/auth.forms',
		'client/helpers/auth.loader',
		'client/helpers/auth.meteor',
		'client/helpers/auth.session',
		'client/helpers/auth.storage',
		'client/scripts/lib/amplify.js',
		'client/scripts/loaders/adaptive-label.js',
		'client/scripts/start.coffee',
		'collections/base/basecollection.coffee',
		'collections/currentusersession.coffee',
		'lib/components/datatables.coffee',
		'lib/extensions/array.coffee',
		'lib/extensions/date.coffee',
		'lib/extensions/strings.coffee',
		'lib/extensions/helpers/_core/core.coffee',
		'lib/extensions/helpers/common/conversion.coffee',
		'lib/extensions/helpers/common/token.coffee',
		'lib/extensions/helpers/application.js',
		'lib/extensions/environment.js',
		'private/templates/email/base/foot.html',
		'private/templates/email/base/head.html',
		'private/templates/email/alert.html',
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
