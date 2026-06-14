const router = require('express').Router()
const { version } = require('../../package.json')

router.get('/', (req, res) => {
    res.json({
        uptime: process.uptime(),
        version,
        env: process.env.NODE_ENV || 'development',
    })
})

module.exports = router