class @ElasticSearchObject

    @index: 'slom'
    @type: null
    @collection: null
    esItem: null
    shouldDelete: false
    item: null

    constructor: (item) ->
        @item = item
        @esItem = @toElasticSearchDocument item
        @shouldDelete = item.es_published and not @esItem

    toElasticSearchDocument: (item = {}) =>
        return item

    upsert: (id) =>
        esServices = Crater.Services.Get Services.ELASTIC_SEARCH

        if @shouldDelete
            esServices.delete @constructor.index, @constructor.type, id
            @constructor.collection.update id, {
                $set:
                    es_published: false
            }
            return

        if not @esItem
            return

        @constructor.collection.update id, {
            $set:
                es_published: true
        }

        esServices = Crater.Services.Get Services.ELASTIC_SEARCH
        esServices.upsert {
            documents: [@esItem]
            index: @constructor.index
            type: @constructor.type
            operation: 'UPSERT'
        }

    @search: (properties) ->
        esServices = Crater.Services.Get Services.ELASTIC_SEARCH
        esServices.search _.extend {
            index: @index
            type: @type
        }, properties

    @setMapping: (settings, mapping) ->
        esServices = Crater.Services.Get Services.ELASTIC_SEARCH
        esServices.setMapping {
            index: @index
            type: @type
            mapping: mapping
            settings: settings
        }

    @clear: ->
        esServices = Crater.Services.Get Services.ELASTIC_SEARCH
        esServices.clear @index, @type

    remove: ->
        esServices = Crater.Services.Get Services.ELASTIC_SEARCH
        esServices.remove @
