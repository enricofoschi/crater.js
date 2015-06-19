class @Crater.Services.Core.Account extends @Crater.Services.Core.Base

    createUserWithEmail: (doc) ->
        schema = Crater.Schema.Get Crater.Schema.Account.EmailSignup

        console.log doc
        console.log check doc, schema