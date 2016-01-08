class @Crater.Services.ThirdParties.ElasticSearch extends @Crater.Services.ThirdParties.Base

    _esAPI = null
    _logServices = null
    esInitialized = null
    @_elasticSearchModels: []

    @AddElasticSearchModel: (model) =>
        @_elasticSearchModels.push model

    constructor: () ->
        _logServices = Crater.Services.Get Services.LOG
        _esAPI = new Crater.Api.ElasticSearch.Core()

    clear: (index, type) ->
        _esAPI.clearMapping index, type

    delete: (index, type, id) ->
        _esAPI.delete index, type, id

    setMapping: (properties) ->
        _esAPI.putMapping properties

    upsert: (properties) ->

        if not esInitialized
            return

        _esAPI.pushDocuments properties

    remove: (properties) ->

        if not esInitialized
            return

        # TBD

    createIndex: (index, settings) =>

        _esAPI.createIndex index, settings

    ensureIndex: =>

        logService = Crater.Services.Get Services.LOG
        logService.Info 'Ensuring Elasticsearch Index'

        for model in @constructor._elasticSearchModels
            if not _esAPI.getIndex model.index
                logService.Info 'Rebuilding Elasticsearch Index from Ensure Index for', model.index
                @rebuildIndex model
            else
                logService.Info 'Elasticsearch Service: OK'
                esInitialized = true

    rebuildIndex: (models) =>

        logService = Crater.Services.Get Services.LOG
        logService.Info 'Rebuilding ElasticSearch Index'

        # Clearing Index
        cleared = []

        models.forEach (model) =>
            return if model in cleared
            cleared.push model
            @clear model.index

        # Pushing Index / Types
        models.forEach (model) =>
            @createIndex model.index, {
                analysis:
                    filter:
                        specialchars_filter:
                            type: 'word_delimiter'
                            type_table: [
                                '# => ALPHA'
                                '@ => ALPHA'
                            ]
                    analyzer:
                        specialchars_analyzer:
                            type: 'custom'
                            tokenizer: 'whitespace'
                            filter: [
                                'lowercase'
                                'specialchars_filter'
                            ]
            }

            @setMapping {
                index: model.index
                type: model.type
                mapping: model.mapping
            }

            #Filter, prepare and push data into ES
            data = model.collection.find(model.filters || {}).fetch()
            @pushToES data, model


        esInitialized = true


    pushToES: (data, esModel) =>
        logService = Crater.Services.Get Services.LOG
        logService.Info 'Preparing data to push into Elastic Search'

        docsByIndex = {}

        for item in data
            try
                item = new esModel(item)
                key = esModel.index + ':' + esModel.type

                docsByIndex[key] = {
                    model: esModel
                    docs: []
                } if not docsByIndex[key]
                docsByIndex[key].docs.push item.esItem # push above where you assign it
            catch e
                _logServices.Error e
                if Meteor.settings.debug
                    throw e

        for own key, value of docsByIndex
            logService.Info 'Pushing  documents'
            @upsert {
                documents: value.docs
                index: value.model.index
                type: value.model.type
                operation: 'UPSERT'
            }
            logService.Info 'Pushed ' + value.docs.length * 2 + ' docs'

    search: (properties) =>
        _esAPI.search properties
