@description('Name of the Cosmos DB account')
param accountName string

@description('Location for the Cosmos DB account')
param location string = resourceGroup().location

@description('Name of the database')
param databaseName string

@description('Enable zone redundancy')
param enableZoneRedundancy bool = false

@description('Tags to apply to the resource')
param tags object = {}

// Cosmos DB Account
resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' = {
  name: accountName
  location: location
  tags: tags
  kind: 'MongoDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: true
    enableMultipleWriteLocations: false
    isVirtualNetworkFilterEnabled: false
    virtualNetworkRules: []
    disableKeyBasedMetadataWriteAccess: false
    enableFreeTier: false
    enableAnalyticalStorage: false
    apiProperties: {
      serverVersion: '7.0'
    }
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 86400
      maxStalenessPrefix: 300
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: enableZoneRedundancy
      }
    ]
    capabilities: [
      {
        name: 'EnableMongo'
      }
    ]
    ipRules: []
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Local'
      }
    }
  }
}

// Cosmos DB Database
resource cosmosDatabase 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases@2024-11-15' = {
  parent: cosmosAccount
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
  }
}

// Collections for the application
var collections = [
  'products'
  'users'
  'orders'
]

resource cosmosCollections 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/collections@2024-11-15' = [for collection in collections: {
  parent: cosmosDatabase
  name: collection
  properties: {
    resource: {
      id: collection
      shardKey: {
        _id: 'Hash'
      }
    }
    options: {
      throughput: 400
    }
  }
}]

// Outputs
@description('Cosmos DB account name')
output accountName string = cosmosAccount.name

@description('Cosmos DB account ID')
output accountId string = cosmosAccount.id

@description('Cosmos DB primary connection string')
@secure()
output primaryConnectionString string = cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString

@description('Cosmos DB primary key')
@secure()
output primaryKey string = cosmosAccount.listKeys().primaryMasterKey

@description('Cosmos DB endpoint')
output documentEndpoint string = cosmosAccount.properties.documentEndpoint
