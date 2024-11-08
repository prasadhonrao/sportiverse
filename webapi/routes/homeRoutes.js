import express from 'express';

const router = express.Router();

router.get('/', (req, res) => {
  res.send('Sai Sports Web API is running...');
});

router.get('/version', (req, res) => {
  res.send('1.0');
});

export default router;
