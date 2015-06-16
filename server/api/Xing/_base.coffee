@Crater.Api.Xing = {}

class @Crater.Api.Xing.Base extends @Crater.Api.OAuth1

    _baseUrl: 'https://api.xing.com/'

    _getTokenSecret: (options) =>
        options.custom.user.getXingAccessTokenSecret()

    _getToken: (options) =>
        options.custom.user.getXingAccessToken()
