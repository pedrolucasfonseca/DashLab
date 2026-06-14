const router = require('express').Router();
const { version } = require('../../package.json')

router.get('/', (req, res) => {
    res.json({ message: 'DashLab API', version });
});

module.exports = router;