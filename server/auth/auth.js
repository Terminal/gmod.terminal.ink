const config = require('config');
const passport = require('passport');
const SteamStrategy = require('passport-steam').Strategy;
const r = require('../db');

passport.serializeUser((user, done) => done(null, user.id));

passport.deserializeUser((id, done) => {
	r.table('users')
		.get(id)
		.then((user) => {
			done(null, user);
		});
});

// DiscordApp
passport.use(new SteamStrategy(
	{
		realm: config.get('steam').realm,
		apiKey: config.get('steam').apiKey,
		returnURL: `${config.get('webserver').location}auth/callback`
	},
	(identifier, profile, done) => {
		if (identifier !== null) {
			r.table('users')
				.insert(profile, {
					conflict: 'replace'
				})
				.run(r.conn)
				.then(() => {
					done(null, profile);
				})
				.catch((err) => {
					throw err;
				});
		}
	}
));

module.exports = passport;
