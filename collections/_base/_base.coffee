@Crater.Collections = {}

Crater.startup ->
    BaseCollectionHolders.push Crater.Collections
    BaseCollection.InitCollections()