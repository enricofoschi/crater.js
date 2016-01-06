global = @

class @NamedCollection extends BaseCollection

    DEFAULT_LANGUAGE = 'en'
    @langs: [DEFAULT_LANGUAGE]

    getKey = (lang) ->
        if lang is DEFAULT_LANGUAGE
            'name'
        else
            'name_' + lang

    @firstByName: (name, options) ->
        name = (name || '').toString().trim().toLowerCase()

        filter = _.extend {
            $or: []
        }, (options || {})

        for lang in @langs

            langFilter = {}
            langFilter['lc_' + getKey(lang)] = name

            filter.$or.push langFilter

        @first filter

    @firstByNameFromCached: (name) ->
        name = (name || '').toString().trim().toLowerCase()

        _.find @allCached(), (obj) =>
            if @MatchByName obj, name
                return true


    @MatchByName: (obj, name) ->
        name = (name || '').trim().toLowerCase()

        for lang in @langs
            if obj['lc_' + getKey(lang)] is name
                return true

        return false

    matchByName: (name) =>
        @constructor.MatchByName @, name

    update: (attr) =>

        attr.part_of = attr.part_of.trim().toLowerCase() if attr.part_of

        for own key, val of attr
            if key.indexOf('name') is 0
                attr['lc_' + key] = (val || '').toLowerCase().trim()

        super attr

    @InitNamedCollection: ->

        origSchema = @schema()

        @schema = =>
            r = _.extend {}, origSchema

            for own key, val of origSchema when key.indexOf('name') is 0

                r['lc_' + key] = {
                    type: String
                    optional: true
                }

            r

        if Meteor.isServer
            Meteor.startup =>

                for lang in @langs
                    indexObj = {}
                    indexObj[getKey(lang)] = 1

                    @_collection._ensureIndex indexObj


                # Sanitizing data
                filter = {
                    $or: []
                }

                for lang in @langs
                    langFilter = {}
                    langFilter['lc_' + getKey(lang)] = null
                    langFilter[getKey(lang)] = {
                        $ne: null
                    }
                    filter.$or.push langFilter

                data = @where filter

                for row in data
                    console.log 'Sanitizing data', row.lc_name, row.lc_name_de, row.name, row.name_de

                    updateObj = {}
                    for lang in @langs
                        key = getKey(lang)
                        updateObj['lc_' + key] = (row[key] || '').toLowerCase()

                    row.update updateObj

