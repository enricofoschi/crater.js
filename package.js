Package.describe({
  name: 'enricofoschi:crater.js',
  version: '0.0.18',
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
		'iron:router',
		'underscore',
		'reactive-var',
		'coffeescript',
		'kaptron:minimongoid@0.9.5',
		'aldeed:collection2',
		'aldeed:autoform',
		'meteor-base',
		'mongo',
		'blaze-html-templates',
		'jquery',
		'session',
		'tracker',
		'accounts-base',
		'alanning:roles',
		'service-configuration',
		'reactive-dict',
        'fastclick',
        'froatsnook:sleep',
        'http',
        'meteorhacks:inject-initial',
		'meteorhacks:subs-manager',
		'arsnebula:reactive-promise'
	]);

	api.use([
		'less@2.5.1'
	], 'client');

	api.use([
		'email',
		'http',
		'meteorhacks:ssr',
		'meteorhacks:async',
		'base64',
        'froatsnook:request',
        'sha',
		'meteorhacks:unblock',
		'meteorhacks:npm'
	], 'server');

	api.addFiles([
		'lib/_base/_base.coffee',
		'lib/extensions/array.coffee',
        'lib/extensions/number.coffee',
		'lib/extensions/date.coffee',
		'lib/extensions/object.coffee',
		'lib/extensions/strings.coffee',
        'collections/_base/_base.coffee',
        'collections/_base/basecollection.coffee',
        'collections/_base/namedcollection.coffee',
		'collections/_base/statemachine.coffee',
        'collections/time/_base.coffee',
        'collections/currentusersession.coffee',
        'collections/email.coffee',
		'collections/error.coffee',
        'lib/helpers/_core/core.coffee',
		'lib/helpers/common/analytics.coffee',
		'lib/helpers/common/conversions.coffee',
		'lib/helpers/common/geo.coffee',
		'lib/helpers/common/token.coffee',
		'lib/helpers/common/number.coffee',
		'lib/helpers/common/paging.coffee',
        'lib/helpers/common/promises.coffee',
        'lib/helpers/common/router.coffee',
		'lib/helpers/common/time.coffee',
		'lib/helpers/common/validation.coffee',
        'lib/helpers/thirdparties/amazon.coffee',
		'lib/helpers/thirdparties/google.coffee',
        'lib/helpers/application.js',
        'lib/schema/_base.coffee',
		'lib/router.coffee',

		/* Users */
		'features/users/lib/_base.coffee',
		'features/users/lib/collections.coffee',
		'features/users/lib/router.coffee',
        'features/users/lib/schemas.coffee',

        /* Features */
        'features/translations/lib/collections.coffee',
	]);

	api.addFiles([
		'client/head.coffee',

		'lib/helpers/common/log.coffee',


		'client/scripts/helpers/animations.coffee',
		'client/scripts/helpers/auth.coffee',
		'client/scripts/helpers/dom.coffee',
		'client/scripts/helpers/forms.coffee',
		'client/scripts/helpers/loader.coffee',
		'client/scripts/helpers/meteor.coffee',
        'client/scripts/helpers/modal.coffee',
		'client/scripts/helpers/notifications.coffee',
		'client/scripts/helpers/seo.coffee',
		'client/scripts/helpers/session.coffee',
		'client/scripts/helpers/static.coffee',
		'client/scripts/helpers/storage.coffee',
		'client/scripts/helpers/template.coffee',
        'client/scripts/helpers/thirdparties/google.coffee',

		'client/scripts/lib/amplify.js',
		'client/scripts/lib/bootbox.min.js',
		'client/scripts/lib/bootstrap.min.js',
		'client/scripts/lib/bootstrap3-typeahead.min.js',
		'client/scripts/lib/noui-slider.js',
		'client/scripts/lib/sweetalert.min.js',
		'client/scripts/lib/vanilla-masker.min.js',
		'client/scripts/loaders/adaptive-label.js',

		'client/styles/lib/animations.css',
		'client/styles/lib/checkbox.css',
		'client/styles/lib/debugger.css',
        'client/styles/lib/noui-slider.css',
		'client/styles/lib/status-line.less',
		'client/styles/lib/sweetalert.less',

		'client/templates/autoform/af_array_field_custom.html',
		'client/templates/autoform/af_array_field_custom.coffee',
        'client/templates/autoform/af_range_slider.html',
        'client/templates/autoform/af_range_slider.coffee',
        'client/templates/autoform/af_simple_tags.html',
		'client/templates/autoform/af_simple_tags.coffee',

        'client/templates/components/paginator.html',
        'client/templates/components/paginator.coffee',
        'client/templates/components/success_icon.html',

        'client/templates/components/cookiebar.html',
        'client/templates/components/cookiebar.coffee',
        'client/templates/components/cookiebar.less',

        'client/templates/components/none.html',

        'client/startup.coffee',

		/* Users Feature */
        'features/users/client/helpers.coffee',
		'features/users/client/signup.html',
        'features/users/client/signup.coffee',
        'features/users/client/login.html',
        'features/users/client/login.coffee',
		'features/users/client/forgot_password.html',
		'features/users/client/forgot_password.coffee',
        'features/users/client/reset_password.html',
        'features/users/client/reset_password.coffee',
        'features/users/client/startup.coffee',
		'features/users/client/verify_email.html',
		'features/users/client/verify_email.coffee',

        /* Translation Feature */
        'features/translations/lib/helpers.coffee',
        'features/translations/client/startup.coffee',

        /* Autoform Fields */
        'features/forms/client/field_switch.html',
        'features/forms/client/field_switch.coffee',
        'features/forms/client/field_switch.css',

		/* Account */
		'features/account/forgot_password.html',
		'features/account/forgot_password.coffee',
		'features/account/login.html',
		'features/account/login.coffee',
		'features/account/reset_password.html'
	], 'client');

	api.addFiles([
        'server/init.coffee',
		'server/api/_base/_base.coffee',
		'server/api/_base/basic_auth.coffee',
		'server/api/_base/oauth1.coffee',
		'server/api/_base/oauth2.coffee',
        'server/api/Amazon/_base.coffee',
        'server/api/Amazon/s3.coffee',
        'server/api/Google/_base.coffee',
		'server/api/LinkedIn/_base.coffee',
        'server/api/LinkedIn/profile.coffee',
		'server/api/ElasticSearch/_base.coffee',
		'server/api/ElasticSearch/core.coffee',
		'server/api/Highrise/_base.coffee',
		'server/api/Highrise/people.coffee',
		'server/api/Mandrill/_base.coffee',
        'server/api/Mandrill/email.coffee',
        'server/api/Xing/_base.coffee',
        'server/api/Xing/authentication.coffee',
		'server/classes/thirdparties/elasticsearch_object.coffee',
        'server/fixtures/_base.coffee',
		'server/fixtures/user.coffee',
		'server/helpers/auth.coffee',
		'server/helpers/collection.coffee',
		'server/helpers/communication.coffee',
		'server/helpers/email.coffee',
        'server/helpers/image.coffee',
        'server/helpers/io.coffee',
		'server/helpers/session.coffee',
		'server/helpers/time.coffee',
		'server/methods/_base/_base.coffee',
		'server/methods/auth/session.coffee',
        'server/methods/core/core.coffee',
        'server/methods/thirdparties/xing.coffee',
        'server/methods/thirdparties/linkedin.coffee',
		'server/methods/thirdparties/elasticsearch.coffee',
		'server/methods/thirdparties/kibana.coffee',
		'server/services/_base/_base.coffee',
        'server/services/core/_base.coffee',
        'server/services/core/log.coffee',
		'server/services/core/statemachine.coffee',
		'server/services/communications/_base.coffee',
        'server/services/communications/email.coffee',
		'server/services/thirdparties/_base.coffee',
		'server/services/thirdparties/amazon.coffee',
        'server/services/thirdparties/xing.coffee',
        'server/services/thirdparties/linkedin.coffee',
		'server/services/thirdparties/elasticsearch.coffee',
		'server/services/thirdparties/highrise.coffee',
        'server/services/thirdparties/kibana.coffee',
		'server/services/config.coffee',
		'server/publications/roles.coffee',
		'server/publications/static.coffee',
		'server/smtp.coffee',
		'server/kadira.coffee',

		/* Users */
		'features/users/server/publications.coffee',
        'features/users/server/publication_helpers.coffee',
		'features/users/server/validation.coffee',
        'features/users/server/methods.coffee',
        'features/users/server/services.coffee',

        /* Features */
        'features/translations/lib/helpers.coffee',
        'features/translations/server/methods.coffee',
        'features/translations/server/publications.coffee',
        'features/translations/server/services.coffee',

        /* Logs */
        'lib/helpers/common/log.coffee'
	], 'server');

});

Package.onTest(function(api) {
  api.use('tinytest');
  api.use('enricofoschi:crater.js');
  api.addFiles('crater.js-tests.js');
});
