@Crater.Api.ElasticSearch = {}

class @Crater.Api.ElasticSearch.Base extends @Crater.Api.Base

    _baseUrl: Meteor.settings.elasticsearch?.url
    _auth: null

    specialCharacters = [
        '\\'
        ' '
        '+'
        '-'
        '&&'
        '||'
        '!'
        '('
        ')'
        '{'
        '}'
        '['
        ']'
        '^'
        '"'
        '~'
        ':'
        '/'
        '#'
    ]

    @PrepareTerm: (term) =>
        term = term.replace /#/g, '_SHARP_'

    @EscapeQuery: (query) =>

        query = @PrepareTerm query

        for specialCharacter in specialCharacters
            if query.indexOf(specialCharacter) > -1
                regEx = new RegExp(specialCharacter.escapeForRegEx(), 'g')
                query = query.replace(regEx, '\\' + specialCharacter)

        query

    constructor: ->
        super {}