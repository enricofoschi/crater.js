class @Crater.Services.ThirdParties.Amazon extends @Crater.Services.ThirdParties.Base

    s3Api = null

    constructor: (@key, @secret, @bucketName, @region) ->

    getS3Api: =>
        aws = Meteor.npmRequire 'aws-sdk'

        aws.config.accessKeyId = @key
        aws.config.secretAccessKey = @secret
        aws.config.region = @region

        new Crater.Api.Amazon.S3 aws, @bucketName

    uploadFile: (path, name, params, callback) =>
        @getS3Api().uploadFile path, name, params, callback