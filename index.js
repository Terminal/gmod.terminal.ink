const app = require('./src');
const r = require('./src/rethinkdb');
const webserverConfig = require('./src/data/webserver.json');
const databaseConfig = require('./src/data/rethinkdb.json');
const autoinitTables = require('./src/data/autoinitTables.json');

const checkDatabase = () =>
  r.dbList()
    .then((dbList) => {
      if (!dbList.includes(databaseConfig.db)) {
        return r.dbCreate(databaseConfig.db);
      }

      return Promise.resolve();
    })
    .then(() =>
      r.tableList())
    .then((tableList) => {
      const promises = [];

      for (let i = 0; i < autoinitTables.length; i += 1) {
        if (!tableList.includes(autoinitTables[i])) {
          promises.push(r.tableCreate(autoinitTables[i]));
        }
      }

      return Promise.all(promises);
    });

checkDatabase()
  .then(() => {
    app.listen(webserverConfig.port, () => {
      console.log('Ready!');
    });
  });
