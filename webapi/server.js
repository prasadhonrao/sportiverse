import express from 'express';

const port = process.env.port || 5000;

const app = express();

app.get('/', (req, res) => {
  res.send('Sai Sports Web API is running');
});

app.listen(port, () => {
  console.log(`Sai Sports Web API is running on port ${port}`);
});
