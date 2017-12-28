const express = require('express');
const config = require('config');
const r = require('./db');
const { inspect } = require('util');

const router = express.Router();

const isAuth = (req, res, next) => {
	let ip = '';

	if (config.get('webserver').cloudflare) {
		ip = req.get('CF-Connecting-IP') || ip || ''; // Set IP to the IP that cloudflare sent
	} else if (config.get('webserver').proxy) {
		ip = req.get('X-Forwarded-For') || ip || ''; // Set IP to the IP that the proxy sent
	}

	// If there was no IP set, set it to the remote address.
	ip = ip || req.connection.remoteAddress;

	// Check if the auth header is correct, and that the webserver allows connections from this IP address
	if (!ip || !config.get('webserver').allow.includes(ip)) {
		res.status(400).json({ error: `The server is not authorised to access this endpoint. Edit config/default.json, and edit the webserver.allow array with ${ip}` });
	} else if (req.get('Authorization') !== config.get('webserver').auth) {
		res.status(400).json({ error: 'Your authorisation header is incorrect. Check you have copied the code correctly.' });
	} else {
		next();
	}
};

router.post('/eval', isAuth, (req, res) => {
	if (req.body.js) {
		try {
			console.log(req.body.js);
			eval(req.body.js); // eslint-disable-line no-eval
		} catch (e) {
			if (e) {
				if (e.stack) console.log(e.stack);
				let error = e;
				if (typeof error !== 'string') {
					error = inspect(error, {
						depth: 0
					});
				}
				res.status(500).json({
					error: 'An error occured',
					output: error
				});
			} else {
				res.status(500).json({ error: 'An unknown error occured' });
			}
		}
	} else {
		res.status(400).json({ error: 'No JS was provided to be executed' });
	}
})
	.get('/bans', async (req, res) => {
		const result = await r.table('bans');
		res.json(result);
	})
	.get('/points', async (req, res) => {
		const result = await r.table('points');
		res.json(result);
	})
	.use('*', (req, res) => {
		console.log(req.originalUrl);
		res.status(404).json({ error: 'This endpoint does not exist, or does not support this HTTP method' });
	});

module.exports = router;
