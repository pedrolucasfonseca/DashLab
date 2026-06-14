const client = require('prom-client')

const registry = new client.Registry()
client.collectDefaultMetrics({ register: registry })

const httpDuration = new client.Histogram({
    name: 'http_request_duration_seconds',
    help: 'Duração das HTTP requests em segundos',
    labelNames: ['method', 'route', 'status'],
    buckets: [0.005, 0.01, 0.05, 0.1, 0.5, 1, 2, 5],
    registers: [registry],
})

const httpErrors = new client.Counter({
    name: 'http_errors_total',
    help: 'Total de respostas com erro (4xx e 5xx)',
    labelNames: ['method', 'route', 'status'],
    registers: [registry],
})

module.exports = { registry, httpDuration, httpErrors }