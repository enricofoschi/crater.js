Helpers.Router.AddRoute {
    path: 'admin/translation/all'
    name: 'admin_translation_all'
    controller: Crater.Routing.Controllers.Admin
    title: ->
        translate 'commons.translations.title'
    action: ->
        @render 'admin.translation.all'
        return
}