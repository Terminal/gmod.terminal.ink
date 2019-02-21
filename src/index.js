const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');

const apiRouter = require('./routes/v1');

// Create an express app
const app = express();

app
  .use(bodyParser.json())
  .use(bodyParser.urlencoded({
    extended: true
  }))
  .use('/api/v1', apiRouter)
  .use(express.static(path.join(__dirname, 'www-data'))); // Pull static files from /src/static

module.exports = app;
