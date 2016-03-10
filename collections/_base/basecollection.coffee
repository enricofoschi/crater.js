global = @

class @BaseCollection extends Minimongoid

    @schema: null
    @stateMachineConfig: null

# overriding function, waiting for pull request https://github.com/Exygy/minimongoid/pull/31 to be approved
# this function sets up all of the attributes to be stored on the model as well as
# setting up the relation methods
    initAttrsAndRelations: (attr = {}, parent = null) ->
# initialize relation arrays to be an empty array, if they don't exist
        for habtm in @constructor.has_and_belongs_to_many
# e.g. matchup.game_ids = []
            identifier = "#{_.singularize(habtm.name)}_ids"
            @[identifier] ||= []
        # initialize relation arrays to be an empty array, if they don't exist
        for embeds_many in @constructor.embeds_many
            @[embeds_many.name] ||= []

        if @constructor.embedded_in and parent
            @[@constructor.embedded_in] = parent


        # load in all the passed attrs
        for name, value of attr
            continue if name.match(/^_id/)
            if name.match(/_id$/) and (value instanceof Meteor.Collection.ObjectID)
                @[name] = value._str
            else if (embeds_many = _.findWhere(@constructor.embeds_many, {name: name}))
# initialize a model with the appropriate attributes
# also pass "self" along as the parent model
                class_name = embeds_many.class_name || _.classify(_.singularize(name))
                @[name] = global[class_name].modelize(value, @)
            else
                @[name] = value

        # load in defaults
        for own attr, val of @constructor.defaults
            @[attr] = val if typeof @[attr] is 'undefined'

        self = @

        # set up belongs_to methods, e.g. recipe.user()
        for belongs_to in @constructor.belongs_to
            relation = belongs_to.name
            identifier = belongs_to.identifier || "#{relation}_id"
            # set up default class name, e.g. "belongs_to: user" ==> 'User'
            class_name = belongs_to.class_name || _.titleize(relation)

            @[relation] = do(relation, identifier, class_name) ->
                (options = {}) ->
# if we have a relation_id
                    if global[class_name] and self[identifier]
                        return global[class_name].find self[identifier], options
                    else
                        return false


        # set up has_many methods, e.g. user.recipes()
        for has_many in @constructor.has_many
            relation = has_many.name
            selector = {}
            unless foreign_key = has_many.foreign_key
# can't use @constructor.name in production because it's been minified to "n"
                foreign_key = "#{_.singularize(@constructor.to_s().toLowerCase())}_id"
            if @constructor._object_id
                selector[foreign_key] = new Meteor.Collection.ObjectID @id
            else
                selector[foreign_key] = @id
            # set up default class name, e.g. "has_many: users" ==> 'User'
            class_name = has_many.class_name || _.titleize(_.singularize(relation))
            @[relation] = do(relation, selector, class_name) ->
                (mod_selector = {}, options = {}) ->
# first consider any passed in selector options
                    mod_selector = _.extend mod_selector, selector
                    # e.g. where {user_id: @id}
                    if global[class_name]
                        HasManyRelation.fromRelation(global[class_name].where(mod_selector, options), foreign_key, @id)


        # set up HABTM methods, e.g. user.friends()
        for habtm in @constructor.has_and_belongs_to_many
            relation = habtm.name
            identifier = "#{_.singularize(relation)}_ids"
            # set up default class name, e.g. "habtm: users" ==> 'User'
            class_name = habtm.class_name || _.titleize(_.singularize(relation))
            @[relation] = do(relation, identifier, class_name) ->
                (mod_selector = {}, options = {}) ->
                    selector = {_id: {$in: self[identifier]}}
                    # first consider any passed in selector options
                    mod_selector = _.extend mod_selector, selector
                    instance = global[class_name].init()
                    filter = (r) ->
                        name = r.class_name || _.titleize(_.singularize(r.name))
                        global[name] == this.constructor
                    inverse = _.find instance.constructor.has_and_belongs_to_many, filter, @
                    inverse_identifier = "#{_.singularize(inverse.name)}_ids"
                    if global[class_name] and self[identifier] and self[identifier].length
                        relation = global[class_name].where mod_selector, options
                        return HasAndBelongsToManyRelation.fromRelation(relation, @, inverse_identifier, identifier,
                            @id)
                    else
                        return HasAndBelongsToManyRelation.new(@, global[class_name], inverse_identifier, identifier,
                            @id)

    @create: (attr) =>
        attr ||= {}
        attr.updatedAt = new Date
        attr.createdAt = new Date

        super attr

    @after_create: (doc) ->
        try
            if @stateMachineConfig
                for own key, config of @stateMachineConfig
                    sm = doc.getStateMachine(key)
                    sm.initStatus()
        catch e

        doc

    update: (attr, partial = false) =>
        attr ||= attr
        attr.updatedAt = new Date

        if not attr.createdAt and not @createdAt
            attr.createdAt = attr.updatedAt
            
        if not @constructor.schema or partial

            for own key, value of attr
                @[key] = value

            @constructor._collection.update @id, {
                $set: attr
            }
        else
            super attr

    @allCached: (identifier) ->
        identifier ||= @_collection._name
        Helpers.Client.MeteorHelper.GetCachedSubscribedData identifier, @

    @cacheSubscribe: (subs, params, identifier, subscription) ->
        subscription ||= @_collection._name
        identifier ||= @_collection._name
        Helpers.Client.MeteorHelper.SubscribeIfNotCached(
            subs
            identifier
            subscription
            params
        )

    @first: (selector = {}, options = {}, defaults = {}) ->
        if typeof(selector) is 'string'
            selector = {
                '_id': selector
            }

        super selector, options

    @firstOrDefault: (selector = {}, options = {}, defaults = {}) ->
        doc = @first selector, options

        if not doc
            doc = @init defaults

        doc

    @firstOrCreate: (attr = {}) ->
        doc = @first attr

        if not doc
            doc = @create attr

        doc

    push: (data) ->
        updateData = {}

        for type, list of data
            updateData[type] = {
                $each: (@constructor.getBaseObject(value) for value in list when value)
            }

        @constructor._collection.update @id, {
            $addToSet: updateData
        }

    pull: (key, value) ->
        updateObj = {}

        updateObj[key] = value

        updateObj = {
            $pull: updateObj
        }

        @constructor._collection.update @id, updateObj

    addToSet: (lists) ->
        updateObj = lists

        @constructor._collection.update @_id, {
            $set:
                updatedAt: new Date()
            $addToSet: updateObj
        }

    removeFromSet: (lists) ->
        updateObj = lists

        @constructor._collection.update @_id, {
            $set:
                updatedAt: new Date()
            $pull: updateObj
        }

    # Localized property
    userLanguage = null


    getLocalizedName: =>
        @getLocalizedProperty 'name'

    @GetLocalizedName: (obj) =>
        @GetLocalizedProperty obj, 'name'

    @GetLocalizedProperty: (obj, property) =>
        if not userLanguage
            userLanguage = Helpers.Translation.GetUserLanguage()
        return obj[property + '_' + userLanguage] || obj[property]

    getLocalizedProperty: (property) =>
        @constructor.GetLocalizedProperty @, property

# Validation
    getValidationContext: (name) ->
        if not @constructor.schema
            null

        @constructor._collection.simpleSchema().namedContext name

    getBaseObject: ->
        @constructor.getBaseObject @

    @getBaseObject: (obj) ->
        if typeof(obj) is 'string'
            return obj

        attr = {}

        for own key, value of obj when key not in ['errors', 'id', '_id', '__is_new']

            continue if typeof value is 'function'

            attr[key] = value

        attr

    isValid: (attr = {}) ->
        if not @constructor.schema
            true
        super attr

    validate: ->
        if not @constructor.schema
            return

        obj = @constructor.getBaseObject @
        validationContext = @getValidationContext @constructor.name

        validationContext.validate obj, {modifier: false}

        if @constructor.schema
            for validationError in validationContext.invalidKeys()
                @error validationError.name, validationContext.keyErrorMessage validationError.name

    error_message: ->
        msg = ''
        for i in @errors
            for key,value of i
                msg += "<strong>#{key}:</strong> #{value}"
            msg

    @ExtraSchema: {
        createdAt:
            type: Date
            autoValue: ->
                if @isInsert
                    new Date
                else if @isUpsert
                    {
                        $setOnInsert: new Date
                    }
                else
                    @unset()
        updatedAt:
            type: Date
            autoValue: ->
                new Date
    }

    getStateMachine: (field = 'status') =>
        new StateMachine @constructor.stateMachineConfig[field], @

    @InitCollections: ->
        for holder in BaseCollectionHolders

            for obj of holder

                try
                    if (
                        obj and
                            obj isnt 'opener' and
                            obj isnt 'localStorage' and
                            obj isnt 'sessionStorage' and
                            obj.indexOf('webkit') is -1 and
                            holder[obj] and
                            holder[obj].prototype instanceof BaseCollection and not holder[obj].simpleSchema and
                            holder[obj]._collection
                    )

                        classDef = holder[obj]

                        if classDef.stateMachineConfig and not classDef.stateMachineSetupInit
                            StateMachineDriven.push classDef
                            classDef.stateMachineSetupInit = true

                        schema = classDef.schema() if classDef.schema

                        continue if not schema

                        schema = _.extend schema, BaseCollection.ExtraSchema

                        classDef.simpleSchema = new SimpleSchema schema

                        classDef._collection.attachSchema classDef.simpleSchema
                catch e
                    if Meteor.isClient
                        Helpers.Log.Error obj + ' cannot be initialized', e

                    throw e if ServerSettings.debug


@StateMachineDriven = []
@BaseCollectionHolders = [
    @
]

BaseCollection.InitCollections()
