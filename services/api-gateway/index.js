const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const app = express();
const PORT = process.env.PORT || 3000;

const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://localhost:3001';
const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL || 'http://localhost:3002';

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());

// Health check — Kubernetes will call this
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'api-gateway',
    timestamp: new Date().toISOString()
  });
});

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'E-Commerce API Gateway', version: '1.0.0' });
});

app.use('/api/users', createProxyMiddleware({
  target: USER_SERVICE_URL,
  changeOrigin: true,
  pathRewrite: { '^/api/users': '/users' },
  on: {
    error: (err, req, res) => {
      res.status(503).json({ error: 'User service unavailable' });
    }
  }
}));

app.use('/api/products', createProxyMiddleware({
  target: PRODUCT_SERVICE_URL,
  changeOrigin: true,
  pathRewrite: { '^/api/products': '/products' },
  on: {
    error: (err, req, res) => {
      res.status(503).json({ error: 'Product service unavailable' });
    }
  }
}));

app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`);
  console.log(`User Service URL: ${USER_SERVICE_URL}`);
  console.log(`Product Service URL: ${PRODUCT_SERVICE_URL}`);
});

module.exports = app;