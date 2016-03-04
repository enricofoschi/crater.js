# crater.js

Very opinionated, quickly hacked meteor experimental boilerplate.
 
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
* State machine
* Intercom integration
* Highrise integration
* Google Tag Manager

and custom features like:

* Data exports to ElasticSearch for indexing
* Log exports to ElasticSearch for Kibana
* Set of helpers and common modules

## Doesn't come with (and should come with) - aka 2do

* Proper testing coverage (it has been developed in an environment where production and live monitoring is preferred to automated testing)
* Enough object composition on top of inheritance (we're still using some cs classes, but up to 2 level inheritance top)
* Refined and standardized naming guidelines for classes, objects, methods, etc...
* ES6 on top of coffeescript
