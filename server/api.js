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
		res.status(400).json({ error: 'The server is not authorised to access this endpoint. Edit config/default.json, and edit the webserver.allow array with the IP address of the server.' });
	} else if (req.get('Authorization') !== config.get('webserver').auth) {
		res.status(400).json({ error: 'Your authorisation header is incorrect. Check you have copied the code correctly.' });
	} else {
		next();
	}
};

router.post('/eval', isAuth, (req, res) => {
	if (req.body.js) {
		try {
			const timeout = setTimeout(() => {
				res.status(500).json({
					error: 'Timeout error (5 seconds). JS code sent to the server must call "res.send()" or other counterpart to return to the server.'
				});
			}, 5000);
			eval(req.body.js); // eslint-disable-line no-eval
			if (res.headersSent) {
				clearTimeout(timeout);
			}
		} catch (e) {
			if (e) {
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
	.use('*', (req, res) => {
		console.log(req.originalUrl);
		res.status(404).json({ error: 'This endpoint does not exist, or does not support this HTTP method' });
	});

module.exports = router;
