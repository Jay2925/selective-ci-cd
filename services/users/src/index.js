import express from 'express'
const app = express()
app.get('/health', (_, res) => res.json({ ok: true }))
app.get('/sum', (req, res) => {
  const a = Number(req.query.a || 0), b = Number(req.query.b || 0)
  res.json({ sum: a + b })
})
const port = process.env.PORT || 8080
app.listen(port, () => console.log(`users on ${port}`))
export default app
