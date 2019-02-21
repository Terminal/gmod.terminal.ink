const config = require('./data/rethinkdb.json');
const r = require('rethinkdbdash')(config);

module.exports = r;
