class @Crater.Services.ThirdParties.Kibana extends @Crater.Services.ThirdParties.Base

    _esAPI = null

    KIBANA_INDEX_PREFIX = 'slom_'
    KIBANA_COLLECTIONS = null
    PERIOD = 8 * 60 * 60 # seconds to export

    constructor: () ->
        _logServices = Crater.Services.Get Services.LOG
        _esAPI = new Crater.Api.ElasticSearch.Core()
        _esAPI._baseUrl = Meteor.settings.kibana.url
        _esAPI._auth = Meteor.settings.kibana.username + ':' + Meteor.settings.kibana.password

    getIndex = (key) ->
        KIBANA_INDEX_PREFIX + key

    formatValue = (obj) ->
        for own key, value of obj
            continue if not value
            if value.isDate
                obj[key] = value.toESFormat()
            else if typeof value is 'object'
                formatValue value


    setMappingForRawField = (obj, mapping) ->
        for own key, value of obj

            if key.toString() is '0'
                break

            mappingKey = key

            continue if not value

            value = _.find(value, (v) -> v) while _.isArray(value) and value.length > 0
            continue if _.isArray(value) # empty array
            continue if not value

            if value.isDate

                if not mapping[mappingKey]
                    mapping[mappingKey] = {
                        type: 'date'
                        format: Date.ES_FORMAT
                    }

            else if typeof value is 'object'
                if not mapping[key]
                    mapping[key] = {
                        properties: {}
                    }

                setMappingForRawField value, mapping[key].properties

            else if typeof value is 'string'
                if not mapping[mappingKey]
                    mapping[mappingKey] = {
                        type: 'string'
                        fields:
                            raw:
                                type: 'string'
                                index: 'not_analyzed'
                    }

    rebuild: (full = false) =>

        console.log 'Rebuilding Kibana'

        initCollections()

        startDate = null

        if not full
            startDate = new Date()
            startDate = startDate.addSeconds(-PERIOD)

        started = new Date()

        for own key, properties of KIBANA_COLLECTIONS
            index = getIndex key

            if full
                console.log 'Clearing mapping and index'
                _esAPI.clearMapping index
                _esAPI.createIndex index

            if not properties.mapping
                properties.mapping = {
                    properties: {}
                }

            filters = properties.filters || {}

            if startDate
                filters.$or = [
                    {
                        createdAt: {
                            $gte: startDate
                        }
                    }
                    {
                        updatedAt: {
                            $gte: startDate
                        }
                    }
                ]

            data = properties.collection.find(filters, {
                fields: properties.fields || {}
            }).fetch()

            console.log 'Results: ' + data.length

            data = _.map data, (d) ->

                ret = d
                if properties.transform
                    ret = properties.transform(d)

                setMappingForRawField d, properties.mapping.properties
                formatValue d

                ret

            if full
                _esAPI.putMapping {
                    index: index
                    type: key
                    mapping: properties.mapping
                }

            _esAPI.pushDocuments {
                operation: 'UPSERT'
                documents: data
                index: index
                type: key
            }

        finished = new Date()

        console.log 'HOLY FUCK: TOOK ' + (finished - started) / 1000 + ' SECONDS'
