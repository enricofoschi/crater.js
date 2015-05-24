class @Helpers.Server.Communication

    @GetPage: (url, timeout=10) ->
        Meteor.http.get(url).content
