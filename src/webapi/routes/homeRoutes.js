import express from 'express';

const router = express.Router();

router.get('/', (req, res) => {
  res.status(200).send('sportiverse web api is running...');
});

router.get('/version', (req, res) => {
  res.status(200).send('1.1');
});

router.get('/status', (req, res) => {
  res.status(200).send('OK');
});

export default router;
