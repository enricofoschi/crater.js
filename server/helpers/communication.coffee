class @Helpers.Server.Communication

    cheerio = Meteor.npmRequire 'cheerio'

    @GetPage: (url, timeout=10) ->
        Meteor.http.get(url).content
