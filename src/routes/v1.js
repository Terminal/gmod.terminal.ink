const express = require('express');
const r = require('../rethinkdb');
const webserverConfig = require('../data/webserver.json');

const router = express.Router();

router
  .use((req, res, next) => {
    if (webserverConfig.auth === req.get('Authorization')) {
      if (req.body && typeof req.body.payload === 'object') {
        req.payload = req.body.payload;
      } else if (req.body && typeof req.body.payload === 'string') {
        req.payload = JSON.parse(req.body.payload);
      } else {
        req.payload = {};
      }
      next();
    } else {
      res.status(400).json({
        message: 'Unauthorized',
        ok: false
      });
    }
  })
  .post('/ulib/ban', (req, res) => {
    r.table('bans')
      .insert(req.payload, {
        conflict: (id, oldban, newban) =>
          oldban
            .merge(newban.without('admin'))
            .merge({
              modified: newban('admin')
            })
      })
      .then(data => res.json(data));
  })
  .post('/ulib/unban', (req, res) => {
    r.table('bans')
      .get(req.payload.id)
      .delete()
      .then(data => res.json(data));
  })
  .post('/ulib/bans', (req, res) => {
    r.table('bans')
      .then(data => res.json(data));
  })
  .post('/ulib/ucl-save-groups', (req, res) => {
    const data = [];

    // Turn key-value into array
    Object.keys(req.payload.groups).forEach((group) => {
      data.push(Object.assign(req.payload.groups[group], {
        id: group
      }));
    });

    r.table('ulib_groups')
      .delete()
      .then(() => {
        r.table('ulib_groups')
          .insert(data)
          .then(result => res.json(result));
      });
  })
  .post('/ulib/ucl-reload-groups', (req, res) => {
    r.table('ulib_groups')
      .then((groups) => {
        const data = {};

        // Turn array into key-value
        groups.forEach((group) => {
          data[group.id] = group;
        });

        res.json(data);
      });
  })
  .post('/ulib/ucl-save-users', (req, res) => {
    const data = [];

    // Turn key-value into array
    Object.keys(req.payload.users).forEach((user) => {
      data.push(Object.assign(req.payload.users[user], {
        id: user
      }));
    });

    r.table('ulib_users')
      .delete()
      .then(() => {
        r.table('ulib_users')
          .insert(data)
          .then(result => res.json(result));
      });
  })
  .post('/ulib/ucl-reload-users', (req, res) => {
    r.table('ulib_users')
      .then((users) => {
        const data = {};

        // Turn array into key-value
        users.forEach((user) => {
          data[user.id] = user;
        });

        res.json(data);
      });
  })
  .post('/ps/create-user', (req, res) => {
    r.table('points')
      .insert({
        id: req.payload.id,
        items: {}
      }, {
        conflict: 'update'
      })
      .then(data => res.json(data));
  })
  .post('/ps/get-data', (req, res) => {
    r.table('points')
      .get(req.payload.id)
      .default({})
      .then(data => res.json(data));
  })
  .post('/ps/set-points', (req, res) => {
    r.table('points')
      .get(req.payload.id)
      .update({ points: req.payload.points })
      .then(data => res.json(data));
  })
  .post('/ps/give-points', (req, res) => {
    r.table('points')
      .get(req.payload.id)
      .update({ points: r.row('points').default(0).add(req.payload.points) })
      .then(data => res.json(data));
  })
  .post('/ps/take-points', (req, res) => {
    r.table('points')
      .get(req.payload.id)
      .update({ points: r.row('points').default(0).sub(req.payload.points) })
      .then(data => res.json(data));
  })
  .post('/ps/give-item', (req, res) => {
    r.table('points')
      .get(req.payload.id)
      .update({
        items: {
          [req.payload.item]: req.payload.data
        }
      })
      .then(data => res.json(data));
  })
  .post('/ps/take-item', (req, res) => {
    r.table('points')
      .get(req.payload.id)
      .replace(r.row.without({
        items: {
          [req.payload.item]: true
        }
      }))
      .then(data => res.json(data));
  })
  .post('/ps/set-data', (req, res) => {
    r.table('points')
      .insert({
        id: req.payload.id,
        items: req.payload.items
      }, {
        conflict: 'update'
      })
      .then(data => res.json(data));
  });

module.exports = router;
