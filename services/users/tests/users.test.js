import request from 'supertest'
import app from '../src/index.js'

test('health', async () => {
  const res = await request(app).get('/health')
  expect(res.status).toBe(200)
  expect(res.body.ok).toBe(true)
})

test('sum', async () => {
  const res = await request(app).get('/sum?a=2&b=3')
  expect(res.body.sum).toBe(5)
})
