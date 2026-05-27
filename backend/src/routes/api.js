const router = require('express').Router();

router.get('/', (req, res) => {
    res.json({ message: 'DashLab API', version: '0.1.0' });
});

module.exports = router;