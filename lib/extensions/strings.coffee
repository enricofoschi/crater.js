String::format = (placeholders, removeEmpty = true) ->

    return @replace /{{[-_a-zA-Z0-9]+}}/g, (match, number) ->
        matchKey = match.substr 2, match.length - 4
        if placeholders[matchKey] or placeholders[matchKey] is 0 then placeholders[matchKey] else (if removeEmpty then '' else match)

String::htmlEncode = ->
    return String(@)
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');

String::stripHtmlTags = ->
    r = @replace /<\/p[^>]*>/g, '\r\n'
    r = r.replace /<li[^>]*>/g, '\r\n- '
    r = r.replace /<br[^>]*>/g, '\r\n'
    r = r.replace /&amp;/g, '&'
    r = r.replace /&quot;/g, '"'
    return r.replace(/<(?:.|\n)*?>/gm, '')

String::escapeForRegEx = ->
    @replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

String::normalize = ->
    @.replace(
        /Â|À|Å|Ã/g, "A").replace(
        /â|à|å|ã/g, "a").replace(
        /Ä/g, "AE").replace(
        /ä/g, "ae").replace(
        /Ç/g, "C").replace(
        /ç/g, "c").replace(
        /É|Ê|È|Ë/g, "E").replace(
        /é|ê|è|ë/g, "e").replace(
        /Ó|Ô|Ò|Õ|Ø/g, "O").replace(
        /ó|ô|ò|õ/g, "o").replace(
        /Ö/g, "OE").replace(
        /ö/g, "oe").replace(
        /Š/g, "S").replace(
        /š/g, "s").replace(
        /ß/g, "ss").replace(
        /Ú|Û|Ù/g, "U").replace(
        /ú|û|ù/g, "u").replace(
        /Ü/g, "UE").replace(
        /ü/g, "ue").replace(
        /Ý|Ÿ/g, "Y").replace(
        /ý|ÿ/g, "y").replace(
        /Ž/g, "Z").replace(
        /ž/, "z");

String::toHTMLFormat = ->
    @htmlEncode().replace /(?:\r\n|\r|\n)/g, '<br />'

String::toUrl = ->
    regEx = /^https?:/i

    if not regEx.test(@)
        return ('http://' + @).toString()

    return @

String::toPrice = ->
    @replace /./g, (c, i, a) ->
        if i and c isnt '.' and ((a.length - i) % 3 is 0) then Helpers.Translation.GetPriceDelimiter() + c else c

String::removePriceDelimiter = ->
    @replace(RegExp(_.escapeRegExp(Helpers.Translation.GetPriceDelimiter()), "g"), '')


String::simpleCrypt = (step) ->

    r = ''

    for i, index in @
        newChar = String.fromCharCode(@charCodeAt(index) + step)
        r += newChar

    r

String::prettyJson = ->
    json = @replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')

    json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, (match) ->
        cls = 'number'
        if /^"/.test(match)
            if /:$/.test(match)
                cls = 'key'
            else
                cls = 'string'
        else if /true|false/.test(match)
            cls = 'boolean'
        else if /null/.test(match)
            cls = 'null'

        '<span class="' + cls + '">' + match + '</span>'
    )