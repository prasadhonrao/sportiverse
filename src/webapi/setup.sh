docker run -d --rm -p 27017:27017 --name sportiverse-db \
-e MONGO_INITDB_ROOT_USERNAME=admin \
-e MONGO_INITDB_ROOT_PASSWORD=password \
mongo

npm run data:import