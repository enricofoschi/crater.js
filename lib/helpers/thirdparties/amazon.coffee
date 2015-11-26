class @Helpers.Amazon

    @GetBucketUrl: (key) ->

        if key.indexOf('http') is 0
            key
        else
            ServerSettings.urls.s3bucket + key