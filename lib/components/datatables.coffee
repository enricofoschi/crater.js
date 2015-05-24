TabularTables = {}

Meteor.isClient && Template.registerHelper 'TabularTables', TabularTables;

Meteor.startup( ->
    TabularTables.Candidates = new Tabular.Table {
        name: "CandidateList"
        collection: Candidate._collection
        pageLength: 5000
        dom: '<f<t>i>'
        columns: [
            {
                data: "firstName"
                title: "First Name"
            }
            {
                data: "lastName"
                title: "Last Name"
            }
            {
                data: "email"
                title: "Email"
            }
        ]
    }
)