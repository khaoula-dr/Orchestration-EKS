const request = require('supertest');
const { app } = require('../app');

describe('GET /health', () => {
  it('répond 200 avec status ok', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});

describe('POST /products', () => {
  it('rejette une création sans price', async () => {
    const res = await request(app).post('/products').send({ name: 'Test' });
    expect(res.statusCode).toBe(400);
  });
});
