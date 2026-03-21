const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 3000;

const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://localhost:3001';
const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL || 'http://localhost:3002';

app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'api-gateway',
    timestamp: new Date().toISOString()
  });
});

app.get('/', (req, res) => {
  res.json({ message: 'E-Commerce API Gateway', version: '1.0.0' });
});

// Users proxy
app.all(['/api/users', '/api/users/*splat'], async (req, res) => {
      try {
    const path = req.path.replace('/api/users', '/users');
    const url = `${USER_SERVICE_URL}${path}`;
    const response = await fetch(url, {
      method: req.method,
      headers: { 'Content-Type': 'application/json' },
      body: req.method !== 'GET' ? JSON.stringify(req.body) : undefined
    });
    const data = await response.json();
    res.status(response.status).json(data);
  } catch (err) {
    res.status(503).json({ error: 'User service unavailable' });
  }
});

// Products proxy
app.all(['/api/products', '/api/products/*splat'], async (req, res) => {
    try {
    const path = req.path.replace('/api/products', '/products');
    const url = `${PRODUCT_SERVICE_URL}${path}`;
    const response = await fetch(url, {
      method: req.method,
      headers: { 'Content-Type': 'application/json' },
      body: req.method !== 'GET' ? JSON.stringify(req.body) : undefined
    });
    const data = await response.json();
    res.status(response.status).json(data);
  } catch (err) {
    res.status(503).json({ error: 'Product service unavailable' });
  }
});

app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`);
  console.log(`User Service URL: ${USER_SERVICE_URL}`);
  console.log(`Product Service URL: ${PRODUCT_SERVICE_URL}`);
});

module.exports = app;