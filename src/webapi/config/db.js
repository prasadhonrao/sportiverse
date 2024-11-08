import mongoose from 'mongoose';

const connectDB = async () => {
  try {
    const {
      MONGODB_HOST = '',
      MONGODB_PORT = '',
      MONGODB_USERNAME = '',
      MONGODB_PASSWORD = '',
      MONGODB_DB_NAME = '',
      MONGODB_DB_PARAMS = '',
    } = process.env;

    // Log environment variables for debugging
    console.log('Environment variables:');
    console.log(`MONGODB_HOST: ${MONGODB_HOST}`.yellow.bold);
    console.log(`MONGODB_PORT: ${MONGODB_PORT}`.yellow.bold);
    console.log(`MONGODB_USERNAME: ${MONGODB_USERNAME}`.yellow.bold);
    console.log(`MONGODB_PASSWORD: ${MONGODB_PASSWORD}`.yellow.bold);
    console.log(`MONGODB_DB_NAME: ${MONGODB_DB_NAME}`.yellow.bold);
    console.log(`MONGODB_DB_PARAMS: ${MONGODB_DB_PARAMS}`.yellow.bold);

    if (!MONGODB_HOST || !MONGODB_DB_NAME) {
      throw new Error('MONGODB_HOST and MONGODB_DB_NAME must be defined');
    }

    let mongodb_uri = 'mongodb://';

    if (MONGODB_USERNAME) {
      mongodb_uri += `${MONGODB_USERNAME}:${MONGODB_PASSWORD}@`;
    }

    mongodb_uri += `${MONGODB_HOST}:${MONGODB_PORT}/${MONGODB_DB_NAME}`;

    if (MONGODB_DB_PARAMS) {
      mongodb_uri += `?${MONGODB_DB_PARAMS}`;
    }

    console.log(`Connecting to MongoDB: ${mongodb_uri}`.yellow.bold);
    await mongoose.connect(mongodb_uri);
    console.log('Connected to MongoDB'.yellow.bold);
  } catch (error) {
    console.error(`Error occurred while connecting to MongoDB: ${error.message}`);
    process.exit(1);
  }
};

export default connectDB;
