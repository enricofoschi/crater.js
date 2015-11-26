class @Helpers.Server.Communication

    extensionsMapping = {
        pdf: ['application/acrobat', 'application/x-pdf', 'application/pdf', 'application/vnd.pdf', 'text/pdf', 'text/x-pdf']
        doc: ['application/msword'],
        docx: ['application/vnd.openxmlformats-officedocument.wordprocessingml.document']
        jpg: ['image/jpeg', 'image/jpg']
        png: ['image/png']
        gif: ['image/gif']
    }

    @GetPage: (url, timeout=10) ->
        Meteor.http.get(url).content

    @GetFile: (url, destination, appendExtension, callback) ->
        destination = (Math.random() * 1000) + '_' + destination
        fullPath = Meteor.settings.tmpFolder + destination

        result = request.getSync url, {
            encoding: null
        }
        body = result.body

        if appendExtension
            header = result.response?.headers?['content-type']

            for own key, value of extensionsMapping
                if header in value
                    fullPath += '.' + key
                    break

        onReady = ->
            fs = Meteor.npmRequire 'fs'
            fs.writeFileSync fullPath, body
            callback null, fullPath

        if result.response?.headers?['content-encoding'] is 'gzip'
            Helpers.Server.Communication.Gunzip body, (error, result) ->
                body = result
                onReady()
        else
            onReady()

    @Gzip: (content, callback) ->
        zlib = Meteor.npmRequire 'zlib'
        zlib.gzip content, callback

    @Gunzip: (content, callback) ->
        zlib = Meteor.npmRequire 'zlib'
        zlib.gunzip content, callback