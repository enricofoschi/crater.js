Helpers.Router.AddRoute {
    path: 'admin/translation/all'
    name: 'admin_translation_all'
    controller: Crater.Routing.Controllers.Admin
    action: ->
        @render 'admin.translation.all', {
            data: {
                title: translate 'commons.translations.title'
            }
        }
        return
}