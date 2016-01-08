class @Crater.Api.Amazon.S3 extends Crater.Api.Amazon.Base

    bucketName = null
    aws = null

    constructor: (_aws, _bucketName) ->
        super {}

        bucketName = _bucketName
        aws = _aws

    uploadFile: (path, name, params, callback) =>
        mime = Meteor.npmRequire 'mime-types'

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
                        ContentType: mime.lookup(path)
                        ACL: 'public-read'
                        Expires: (new Date()).addDays(60)
                    }, params || {}

                    params.Body = result

                    api.upload(params).send(callback)
                )
            else
                callback err, null


    updateAmazonMimeTypes: (marker = null)  ->
        params = {
            params: {
                Bucket: bucketName
                Marker: marker
            }
        }

        api = new aws.S3(params)

# Step 1: fetch all (up to 1000 each time) of the objects
        api.listObjects (err, data) =>
            if err
                console.log 'Error while fetching the objects'
                console.log err, err.stack
                return false
            else
                console.log 'Loaded ' + data.Contents.length + ' items from S3'
                if data.Contents.length < 1
                    console.log 'All started'
                    return true

                i = 0
                while i < data.Contents.length
                    objectKey = data.Contents[i].Key
                    @updateAmazonMimeTypesObject api, objectKey

                    if i is data.Contents.length - 1
                        marker = objectKey

                    i++

                @updateAmazonMimeTypes marker


    updateAmazonMimeTypesObject: (api, objectKey) ->
        mime = Meteor.npmRequire 'mime-types'

        objectParams = {
            Bucket: bucketName
            Key: objectKey
        }

# Step 2: get meta data for each object
        api.headObject objectParams, (err, data) ->
            if err
                console.log 'Fetching Head Error for: ' + objectKey
                console.log err, err.stack
                return false
            else
                copyObjectParams = {
                    Bucket: bucketName
                    CopySource: bucketName + '/' + objectKey
                    Key: objectKey
                    ContentEncoding: 'gzip'
                    ContentType: mime.lookup(objectKey)
                    ACL: 'public-read'
                    Expires: new Date(data.Expires)
                    ContentDisposition: data.ContentDisposition
                    MetadataDirective: 'REPLACE'
                }

                if mime.lookup(objectKey) is data.ContentType
                    return true

# Step 3: overwrite object with modified metadata
                api.copyObject copyObjectParams, (copyErr, copyData) ->
                    if err
                        console.log 'Copy Error for: ' + objectKey
                        console.log copyErr, copyErr.stack
                        return false
                    else
                        console.log 'Updated: ' + objectKey
