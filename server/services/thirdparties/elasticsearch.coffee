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

    rebuildIndex: (models, collection) => # Why am I doing this? Because I need to access to Companies collection and since Crater is public and we don't want to put our BI inside it. Can I do this?

        logService = Crater.Services.Get Services.LOG
        logService.Info 'Rebuilding ElasticSearch Index'
        for model in models
            @clear model.index

        for model in models
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

            if model.IsUsers
                # Rebuilding users
                users = Meteor.users.find(model.UsersFilter || {}).fetch()

                @pushUsers users

            else
                #Rebuilding companies
                @pushToES collection, model


        esInitialized = true

    pushUsers: (users) =>
        logService = Crater.Services.Get Services.LOG

        docsByIndex = {}
        for user in users
            try
                user = MeteorUser.GetDefinedUser user
                if user.getESObject
                    userEs = new user.getESObject()
                    if userEs.esItem
                        esModel = MeteorUser.GetUserType(user).ESModel
                        key = esModel.index + ':' + esModel.type
                        docsByIndex[key] = {
                            model: esModel
                            docs: []
                        } if not docsByIndex[key]
                        docsByIndex[key].docs.push userEs.esItem
            catch e
                _logServices.Error e
                if Meteor.settings.debug
                    throw e

        for own key, value of docsByIndex
            #console.log docsByIndex
            @upsert {
                documents: value.docs
                index: value.model.index
                type: value.model.type
                operation: 'UPSERT'
            }

            logService.Info 'Pushed ' + value.docs.length + ' docs'

    pushToES: (object, model) =>
        console.log 'inside pushToES'
        logService = Crater.Services.Get Services.LOG

        docsByIndex = {}
        for item in object
            try
                model.esItem=item
                item = model.esItem
                if item
                    esModel = Feature_Company.ElasticSearch
                    key = esModel.index + ':' + esModel.type
                    console.log 'here'
                    docsByIndex[key] = {
                        model: esModel
                        docs: []
                    } if not docsByIndex[key]
                    docsByIndex[key].docs.push item
            catch e
                _logServices.Error e
                if Meteor.settings.debug
                    throw e

            for own key, value of docsByIndex
            #console.log docsByIndex
                @upsert {
                    documents: value.docs
                    index: 'slom'
                    type: 'companies'
                    operation: 'UPSERT'
                }

    search: (properties) =>
        _esAPI.search properties
