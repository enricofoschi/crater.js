# crater.js

Very opinionated meteor experimental boilerplate, designed to fit a large scale production app.
 
It includes a number of client + server packages, helpers and common features.

## Comes with:

* LESS
* FontAwesome
* Bootstrap
* CoffeeScript
* Mailgun API Integration (w/ Blaze based template parsing)
* Modal Dialogs
* Users Server & Client Sessions (logged in & anonymous)
* Local Storage w/ Amplify
* DataTables Templates (aldeed:tabular)
* Autoform (aldeed:autoform)
* Collection 2 (aldeed:collection2) w/ MinimongoId integration
* Kadira Setup
* Spiderable - Longer Timeout

and custom features like:

* Data exports to ElasticSearch for indexing
* Log exports to ElasticSearch for Kibana
* Set of helpers and common modules

## Doesn't come with (and should come with)

* Proper testing coverage (it has been developed in an environment where production and live monitoring is preferred to automated testing)
* Enough object composition on top of inheritance (we're still using some cs classes, but up to 2 level inheritance top)
