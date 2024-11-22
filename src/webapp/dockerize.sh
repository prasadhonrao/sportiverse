# Dev image build
docker build --build-arg REACT_APP_BASE_API_URI=http://localhost:5000 -t prasadhonrao/sportiverse-webapp:dev .
docker push prasadhonrao/sportiverse-webapp:dev

# Prod image build
# docker build --build-arg REACT_APP_BASE_API_URI=http://sportiverse.webapi -t prasadhonrao/sportiverse-webapp:prod .
# docker push prasadhonrao/sportiverse-webapp:prod