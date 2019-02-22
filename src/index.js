const express = require('express');
const path = require('path');
const bodyParser = require('body-parser');
const handlebars = require('express-handlebars');

const apiRouter = require('./routes/v1');

// Create an express app
const app = express();

app
  .set('views', path.join(__dirname, 'views'))
  .set('view engine', 'handlebars')
  .set('json spaces', 2)
  .engine('handlebars', handlebars({
    defaultLayout: 'main',
    layoutsDir: path.join(__dirname, 'views', 'layouts'),
    partialsDir: path.join(__dirname, 'views', 'partials')
  }))
  .use(bodyParser.json())
  .use(bodyParser.urlencoded({
    extended: true
  }))
  .use((req, res, next) => {
    res.locals = {};
    if (req.get('User-Agent').toLowerCase().includes('awesomium')) {
      res.locals.awesomium = true;
    }

    next();
  })
  .get('/', (req, res) => {
    res.render('main');
  })
  .get('/loading', (req, res) => {
    res.render('loading', {
      layout: 'fullscreen'
    });
  })
  .use('/api/v1', apiRouter)
  .use(express.static(path.join(__dirname, 'www-data'))); // Pull static files from /src/static

module.exports = app;
