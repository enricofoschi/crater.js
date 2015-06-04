(function onAdaptiveLabel(globalContext) {
	"use strict";

	/* Many thanks to http://codepen.io/aaronbarker/pen/tIprm */
	Helpers.Client.Application.addTemplateLoadedCallback('adaptive-label', function adaptiveLabelWrapper() {
		var onClass = "on";
		var showClass = "active";

		$(".adaptive-field-wrapper").find("input,textarea,select").bind("checkval", function () {
			var label = $(this).prev("label");

			if (this.value !== "" || this.tagName === 'SELECT') {
				label.addClass(showClass);
			} else {
				label.removeClass(showClass);
			}
		}).on("keyup", function onKeyUp() {
			$(this).trigger("checkval");
		}).on("focus", function onFocus() {
			$(this).prev("label").addClass(onClass);
		}).on("blur", function onBlur() {
			$(this).prev("label").removeClass(onClass);
		}).trigger("checkval");
	});

})(this);
