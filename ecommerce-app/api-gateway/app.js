const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();

const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://user-service:3000';
const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL || 'http://product-service:3000';
const ORDER_SERVICE_URL = process.env.ORDER_SERVICE_URL || 'http://order-service:3000';

app.get('/health', (req, res) => res.json({ status: 'ok', service: 'api-gateway' }));

// /api/users/*  -> user-service/*
app.use(
  '/api/users',
  createProxyMiddleware({
    target: USER_SERVICE_URL,
    changeOrigin: true,
    pathRewrite: { '^/api/users': '/users' },
  })
);

// /api/products/* -> product-service/*
app.use(
  '/api/products',
  createProxyMiddleware({
    target: PRODUCT_SERVICE_URL,
    changeOrigin: true,
    pathRewrite: { '^/api/products': '/products' },
  })
);

// /api/orders/* -> order-service/*
app.use(
  '/api/orders',
  createProxyMiddleware({
    target: ORDER_SERVICE_URL,
    changeOrigin: true,
    pathRewrite: { '^/api/orders': '/orders' },
  })
);

module.exports = app;
