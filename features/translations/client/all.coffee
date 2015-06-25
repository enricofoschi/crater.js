((template) =>

    selectedLanguage = new ReactiveVar()

    Crater.startup ->
        TabularTables.InitTableHelper(template, 'Translations')
    , 101

    template.helpers {
        'languages': ->
            GlobalSettings.languages
        'isSelected': ->
            @ is selectedLanguage.get()
        'selector': ->
            {
                lang: selectedLanguage.get()
            }
    }

    template.events {
        'change .ddl-lang': (e, t) ->
            selectedLanguage.set $(e.target).val()
    }

    template.onCustomCreated = =>
        selectedLanguage.set Helpers.Translation.GetUserLanguage()

)(Helpers.Client.TemplatesHelper.Handle('admin.translation.all'))