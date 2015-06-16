class @Crater.Api.LinkedIn.Profile extends @Crater.Api.LinkedIn.Base

    getProfileInfo: (user, callback) =>

        options = {
            custom:
                user: user
        }

        fields = [
            'id'
            'first-name'
            'last-name'
            'maiden-name'
            'formatted-name'
            'headline'
            'location'
            'industry'
            'num-connections'
            'summary'
            'specialties'
            'positions'
            'picture-url'
            'picture-urls::(original)'
            'public-profile-url'
        ]

        url = 'people/~:('
        url += (field for field in fields).join ','
        url += ')?format=json'

        @Call 'get', url, options, (e, r) =>
            if e
                callback e, null
            else
                callback null, r.data