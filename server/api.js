const express = require('express');
const config = require('config');
const r = require('./db');

const router = express.Router();

const isAuth = (req, res, next) => {
	if (req.get('Authorization') === config.get('webserver').auth) {
		next();
	} else {
		res.status(400).json({ error: 'You have not authenticated' });
	}
};

router.get('/ps/:id', isAuth, (req, res) => {
	r.table('pointshop')
		.get(req.params.id)
		.run(r.conn)
		.then((result) => {
			res.json(result || {});
		})
		.catch(() => {
			res.status(500).json({ error: 'An error occured while pinging RethinkDB' });
		});
})
	.post('/ps/:id/setpoints', isAuth, (req, res) => {
		r.table('pointshop')
			.insert({
				id: req.params.id,
				points: req.body.points,
			}, {
				conflict: 'update'
			})
			.then(() => {
				res.json({ code: 200 });
			})
			.catch(() => {
				res.status(500).json({ code: 500, error: 'An error occured while pinging RethinkDB' });
			});
	})
	.post('/ps/:id/addpoints', isAuth, (req, res) => {
		r.table('pointshop')
			.insert({
				id: req.params.id,
				points: r.row('points').add(req.body.points).default(0),
			}, {
				conflict: 'update'
			})
			.then(() => {
				res.json({ code: 200 });
			})
			.catch(() => {
				res.status(500).json({ code: 500, error: 'An error occured while pinging RethinkDB' });
			});
	})
	.post('/ps/:id/giveitem', isAuth, (req, res) => {
		r.table('pointshop')
			.insert({
				id: req.params.id,
				items: r.row('items').append({
					id: req.body.itemid,
					data: req.body.itemdata
				}).default([])
			}, {
				conflict: 'update'
			})
			.then(() => {
				res.json({ code: 200 });
			})
			.catch(() => {
				res.status(500).json({ code: 500, error: 'An error occured while pinging RethinkDB' });
			});
	})
	.post('/ps/:id/takeitem', isAuth, (req, res) => {
		r.table('pointshop')
			.insert({
				id: req.params.id,
				items: r.row('items').difference(req.body.itemid).default([])
			}, {
				conflict: 'update'
			})
			.then(() => {
				res.json({ code: 200 });
			})
			.catch(() => {
				res.status(500).json({ code: 500, error: 'An error occured while pinging RethinkDB' });
			});
	})
	.post('/ps/:id', isAuth, (req, res) => {
		r.table('pointshop')
			.insert({
				id: req.params.id,
				points: req.body.points,
				items: req.body.items
			}, {
				conflict: 'update'
			})
			.then(() => {
				res.json({ code: 200 });
			})
			.catch(() => {
				res.status(500).json({ code: 500, error: 'An error occured while pinging RethinkDB' });
			});
	});

module.exports = router;
