class @Crater.Api.Amazon.S3 extends Crater.Api.Amazon.Base

    bucketName = null
    aws = null

    constructor: (_aws, _bucketName) ->
        super {}

        bucketName = _bucketName
        aws = _aws

        mime = Meteor.npmRequire 'mime-types'

    uploadFile: (path, name, params, callback) =>
        #@_logService.Info 'Reading file ' + path
        Helpers.Server.IO.ReadFile path, (err, data) ->
            if not err
                api = new aws.S3({
                    apiVersion: '2006-03-01'
                })

                data = Helpers.Server.Communication.Gzip(data, (error, result) ->
                    params = _.extend {
                        Bucket: bucketName
                        Key: name
                        ContentEncoding: 'gzip'
                        ContentType: 'image/jpeg'
                        ACL: 'public-read'
                        Expires: (new Date()).addDays(60)
                    }, params || {}

                    params.Body = result

                    api.upload(params).send(callback)
                )
            else
                callback err, null
