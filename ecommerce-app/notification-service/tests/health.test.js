const request = require('supertest');
const app = require('../app');

describe('GET /health', () => {
  it('répond 200 avec status ok', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});

describe('POST /notifications', () => {
  it('rejette une notification sans message', async () => {
    const res = await request(app).post('/notifications').send({ userId: 1 });
    expect(res.statusCode).toBe(400);
  });
});
