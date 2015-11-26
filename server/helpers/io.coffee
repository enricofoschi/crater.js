class @Helpers.Server.IO

    images = [
        'jpg'
        'jpeg'
        'gif'
        'png'
    ]

    getFs = ->
        Meteor.npmRequire 'fs'

    @ReadFile: (path, callback) ->
        getFs().readFile(path, callback)

    @WriteFileSync: (path, content, encoding = 'utf8') ->
        getFs().writeFileSync path, content, encoding

    @Exists: (path) ->
        getFs().existsSync path

    @ReadFileSync: (path, encoding) ->
        getFs().readFileSync path, encoding

    @DeleteFile: (path) =>
        getFs().unlink path, (err) ->
            throw err if err

    @CheckFilePathFromClient: (path) ->
        check path, String

        if path.indexOf('../') > -1 or path.indexOf('//') > -1 or path.indexOf('\\\\') > -1
            throw 'Unauthorized'

    @GetFileExtension: (path) ->
        index = path.lastIndexOf('.')
        if index > -1 and index < path.length - 1
            extension = path.substr(index + 1).toLowerCase()
            return extension if extension in images
        null

    @CreateFolder: (path) ->
        mkdirp = Meteor.npmRequire 'mkdirp'
        mkdirp.sync path

    @ExportToCsv: (path, list) =>
        csv = []

        for item in list
            row = []
            for own key, value of item
                row.push '"' + (value || '').toString().replace(/"/g, '""') + '"'

            csv.push row.join(',')

        @WriteFileSync path, csv.join('\n')

