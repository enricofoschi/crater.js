class @Crater.Api.ElasticSearch.Core extends Crater.Api.ElasticSearch.Base

    pushDocuments: (properties) =>

        return if Meteor.settings.elasticsearch.disable

        bulk = []

        for doc in properties.documents when doc?._id
            if properties.operation is 'UPSERT'
                bulk.push {
                    update:
                        _id: doc._id
                        _index: properties.index
                        _type: properties.type
                }
                bulk.push {
                    doc: doc
                    doc_as_upsert: true
                }

        return if not bulk.length

        bulks = bulk.splitIntoChunks 50000

        for bulk in bulks
            body = ''

            console.log 'Bulk objects: ' + bulk.length

            for obj in bulk
                body += EJSON.stringify obj
                body += "\n"

            HTTP.post @_baseUrl + '_bulk', {
                content: body
                auth: @_auth
            }

    getIndex: (index) =>
        return true if Meteor.settings.elasticsearch.disable

        try
            HTTP.get @_baseUrl + index
            return true
        catch e
            return false

    createIndex: (index, settings) =>

        return if Meteor.settings.elasticsearch.disable

        HTTP.call 'GET', @_baseUrl + index, {}, (error, response) ->
            if response is not 200
                HTTP.post @_baseUrl + index, {
                    content: EJSON.stringify({
                        settings: settings || {}
                    })
                    auth: @_auth
                }

                @_logService.Info 'ES: Created index ' + index
            else
                @_logService.Info 'ES: Skipped create index: ' + index + '; Already exists'

    delete: (index, type, id) =>

        return if Meteor.settings.elasticsearch.disable

        try
            console.log 'Deleting', index, type, id
            HTTP.del @_baseUrl + index + '/' + type + '/' + id
        catch e
            if Meteor.settings.debug and JSON.stringify(e).indexOf('404') is -1
                console.log e

    putMapping: (properties) =>

        return if Meteor.settings.elasticsearch.disable

        # Creating mapping
        obj = {}
        obj[properties.type] = properties.mapping

        @_logService.Info 'ES: Creating mapping for ' + properties.index

        HTTP.put @_baseUrl + properties.index + '/_mapping/' + properties.type, {
            content: EJSON.stringify obj
            auth: @_auth
        }

        @_logService.Info 'ES: Mapping Set for ' + properties.index

    clearMapping: (index, type) =>
        return if Meteor.settings.elasticsearch.disable

        try
            HTTP.del @_baseUrl + index + (if type then ('/' + type) else ''), {
                auth: @_auth
            }
            @_logService.Info 'Mapping cleared'
        catch e
            if e.response.statusCode is 404
                console.log 'Mapping was not existing, not a big deal'
                return
            else
                @_logService.Error e



    search: (properties) =>

        url = @_baseUrl + properties.index + '/' + properties.type + '/_search'

        content = EJSON.stringify properties.dsl

        response = HTTP.get url, {
            content: content
            auth: @_auth
        }

        data = EJSON.parse(response.content)

        aggregations = {}

        for own key, value of (data.aggregations || {})
            aggregations[key] = ({
                key: bucket.key
                count: bucket.doc_count
            } for bucket in value.buckets)

        {
            data: data.hits?.hits
            aggregations: aggregations
        }

