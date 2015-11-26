Meteor.publish 'static', (lang, contents) ->

    for content in contents

        fileContent = Helpers.Server.IO.ReadFileSync(Meteor.settings.privateFolder + 'static/' + lang + '/' + content).toString()

        fileContent = fileContent.format {
            imgPath: Meteor.settings.urls.imgs
        }, false

        @added 'static_collection', content, {
            content: fileContent
        }
    @ready()