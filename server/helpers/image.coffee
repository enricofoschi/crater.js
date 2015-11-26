class @Helpers.Server.Image

    @Rewrite: (properties, callback) ->
        sharp = Meteor.npmRequire 'sharp'

        logService = Crater.Services.Get Services.LOG
        logService.Info 'Rewriting ' + properties.source
        img = sharp(properties.source)
        img.interpolateWith(sharp.interpolator.nohalo).quality(100).toFile(properties.source, (error) ->
            callback error, true
        )

    @Resize: (properties, callback) ->

        sharp = Meteor.npmRequire 'sharp'

        logService = Crater.Services.Get Services.LOG

        logService.Info 'Resizing ' + properties.source + ' to ' + properties.destination

        img = sharp(properties.source)

        resize = ->
            if properties.crop?.rotation
                img = img.rotate parseInt(properties.crop.rotation)

            if properties.width or properties.height
                img = img.resize(properties.width, properties.height)

            img.interpolateWith(sharp.interpolator.nohalo).quality(92).toFile(properties.destination, (error) ->
                callback error, true
            )

        if properties.crop

            img.metadata (err, metadata) ->
                if err
                    callback err, null
                else
                    if properties.originalCrop
                        x = properties.crop.x
                        y = properties.crop.y
                        width = properties.crop.width
                        height = properties.crop.height
                    else
                        x = parseInt(properties.crop.x * metadata.width)
                        y = parseInt(properties.crop.y * metadata.height)
                        width = parseInt(properties.crop.width * metadata.width)
                        height = parseInt(properties.crop.height * metadata.height)

                    if x < 0 or x > metadata.width
                        x = 0
                    if y < 0 or y > metadata.height
                        y = 0

                    if width + x > metadata.width
                        width = metadata.width - x

                    if height + y > metadata.height
                        height = metadata.height - y

                    console.log 'Cropping: ', y, x, width, height

                    img = img.extract(y, x, width, height)
                    resize()


        else
            resize()