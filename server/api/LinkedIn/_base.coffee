@Crater.Api.LinkedIn = {}

class @Crater.Api.LinkedIn.Base extends @Crater.Api.OAuth2

    _authenticationType: 'token'
    _baseUrl: 'https://api.linkedin.com/v1/'

    _getToken: (options) =>
        options.custom.user.getLinkedInAccessToken()