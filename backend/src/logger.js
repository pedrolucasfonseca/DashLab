const pino = require('pino')

module.exports = pino({
    level: process.env.LOG_LEVEL || 'info',
    base: { service: 'dashlab-backend', env: process.env.NODE_ENV },
})