/* Main Application Load Events */
(function onRun(main) {
	"use strict";

	var templateLoadedCallbacks = {}; // available callbacks that could run on template.render
	var templatesWithCallback = {}; // template subscribtion to template callbacks

	main.addCallbacksToTemplate = function addCallbacksToTemplate(templateName, callbacks) {
		templatesWithCallback[templateName] = callbacks;
	};

	main.addTemplateLoadedCallback = function addTemplateLoadedCallback(id, templateLoadedCallback) {
		templateLoadedCallbacks[id] = templateLoadedCallback;
	};

	/* Triggering all available callbacks for this template */
	function triggerLoaders(template) {
		var templateName = template.view.name;

		var templatesCallback = templatesWithCallback[templateName];

		if(templatesCallback) {
			var availableCallbacks = _.keys(templateLoadedCallbacks);

			var actualCallbacks = _.intersection(templatesCallback, availableCallbacks);

			_.each(actualCallbacks, function onEach(callback) {
				templateLoadedCallbacks[callback](template);
			});
		}
	}

	if(Meteor.isClient) {
		Meteor.startup(function onStartupTemplate() {
			for (var property in Template) {
				if (Blaze.isTemplate(Template[property])) {
					var template = Template[property];
					template.onRendered(function () {
						triggerLoaders(this);
					});
				}
			}
		});
	}
})(Helpers.Core.ensure('Helpers.Client.Application'));