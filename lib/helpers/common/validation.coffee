class @Helpers.Validation

    @IsEmail: (str) =>
        emailReg = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/
        emailReg.test str