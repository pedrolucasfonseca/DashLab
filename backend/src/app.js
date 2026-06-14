const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const healthRoutes = require('./routes/health');
const apiRoutes = require('./routes/api');
const pinoHttp = require('pino-http')
const logger = require('./logger');
const { registry, httpDuration, httpErrors } = require('./prom')
const metricsRoutes = require('./routes/metrics')

const app = express();

app.use(helmet());
app.use(cors({ origin: process.env.ALLOWED_ORIGIN }));
app.use(pinoHttp({ logger }))
app.use(express.json());
app.use((req, res, next) => {
    const end = httpDuration.startTimer()
    res.on('finish', () => {
        const labels = { method: req.method, route: req.path, status: res.statusCode }
        end(labels)
        if (res.statusCode >= 400) httpErrors.inc(labels)
    })
    next()
})
app.use('/status', metricsRoutes)
app.use('/health', healthRoutes);
app.use('/api', apiRoutes);
app.get('/metrics', async (req, res) => {
    res.set('Content-Type', registry.contentType)
    res.end(await registry.metrics())
})

module.exports = app;