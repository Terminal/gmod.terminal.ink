const express = require('express');
const config = require('config');
const r = require('./db');

const router = express.Router();
const AsyncFunction = Object.getPrototypeOf(async function(){}).constructor;

const isAuth = (req, res, next) => {
	if (req.get('Authorization') === config.get('webserver').auth) {
		next();
	} else {
		res.status(400).json({ error: 'You have not authenticated' });
	}
};

router.post('/eval', isAuth, (req, res) => {
	eval(req.body.js);
});

module.exports = router;
