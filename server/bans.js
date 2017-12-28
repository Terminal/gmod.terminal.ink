const express = require('express');
const r = require('./db');

const router = express.Router();

router.get('/', async (req, res) => {
	const result = await r.table('bans');
	res.json(result);
});

module.exports = router;
