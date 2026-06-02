const router = require('express').Router();

router.get('/', (req, res) => {
    res.json({ message: 'DashLab API', version: '0.3.0' });
});

module.exports = router;