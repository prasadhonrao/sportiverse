import express from 'express';

const router = express.Router();

router.get('/', (req, res) => {
  res.status(200).send('sportiverse web api is running...');
});

router.get('/version', (req, res) => {
  res.status(200).send('1.0');
});

export default router;
