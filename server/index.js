const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const config = require('config');
const express = require('express');
const session = require('express-session');
const path = require('path');
const auth = require('./auth/auth');
const authM = require('./auth');
const bansM = require('./bans');
const docsM = require('./docs');
const apiM = require('./api');
const i18n = require('i18n');

// Create an express app
const app = express();

i18n.configure({
	directory: path.join(__dirname, '..', 'locales'),
	cookie: 'lang',
	defaultLocale: 'en-gb',
	autoReload: true,
	updateFiles: false
});

app.set('views', path.join(__dirname, 'dynamic')) // Allocate views to be used
	.set('view engine', 'pug')
	.use(cookieParser(config.get('webserver').secret)) // Set cookie secret
	.use(session({
		secret: config.get('webserver').secret,
		resave: true,
		saveUninitialized: true,
		proxy: true
	}))
	.use(i18n.init)
	.use(auth.initialize())
	.use(auth.session())
	.use(bodyParser.json())
	.use(bodyParser.urlencoded({
		extended: true
	}))
	.get('/', (req, res) => {
		res.render('index.pug');
	})
	.get('/load', (req, res) => {
		res.render('load.pug');
	})
	.use('/auth', authM)
	.use('/api', apiM)
	.use('/bans', bansM)
	.use('/docs', docsM)
	.use(express.static(path.join(__dirname, 'static'))) // Pull static files from /src/static
	.use('*', (req, res) => {
		// Give off a 404 if the chain ends here
		res.status(404).render('error.pug', { status: 404, message: 'Not found' });
	})
	.listen(config.get('webserver').port);
