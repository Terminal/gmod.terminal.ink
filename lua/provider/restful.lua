--[[

	RESTful RethinkDB
	The eval mess

--]]

-- THIS MUST BE A HTTPS LINK.
-- http is supported, but will expose your eval endpoint almost immediately
-- Please use a string of random characters, preferably a 512 bit hex hash.

local API_URL = 'http://127.0.0.1:8080/api/eval'
local AUTH = 'authentication'

local function eval(js, callback)
	http.Post(API_URL, {
		js = js
	}, function(body)
		print(body)
		if callback then
			return callback(util.JSONToTable(body))
		end
	end , nil, {
		Authorization = AUTH
	})
end

local function createUser(ply, callback)
	eval(
		string.format(
			[[
				r.table('users')
					.insert({
						id: "%s",
						items: {}
					}, {
						conflict: 'update'
					})
					.run()
					.then((result) => {
						res.json(result)
					})
			]],
			ply:SteamID64() or 'null'
		),
		function(body)
			callback()
		end
	)
end

function PROVIDER:GetData(ply, callback)
	eval(
		string.format(
			[[
				r.table('users')
					.get("%s")
					.run()
					.then((result) => {
						res.json(result)
					})
			]],
			ply:SteamID64() or 'null'
		),
		function(body)
			callback(
				body.points or 0,
				body.items or {}
			)
		end
	)
end

function PROVIDER:SetPoints(ply, set_points)
	createUser(
		ply,
		function()
			eval(
				string.format(
					[[
						r.table('users')
							.get("%s")
							.update({ points: %s })
							.run()
							.then((result) => {
								res.json(result)
							})
					]],
					ply:SteamID64() or 'null',
					set_points
				),
				nil -- Nothing needs to be returned
			)
		end
	)
end

function PROVIDER:GivePoints(ply, points)
	createUser(
		ply,
		function()
			eval(
				string.format(
					[[
						r.table('users')
							.get("%s")
							.update({
								points: r.row('points').default(0).add(%s)
							})
							.run()
							.then((result) => {
								res.json(result)
							})
					]],
					ply:SteamID64() or 'null',
					points
				),
				nil -- Nothing needs to be returned
			)
		end
	)
end

function PROVIDER:TakePoints(ply, points)
	createUser(
		ply,
		function()
			eval(
				string.format(
					[[
						r.table('users')
							.get("%s")
							.update({
								points: r.row('points').default(0).sub(%s)
							})
							.run()
							.then((result) => {
								res.json(result)
							})
					]],
					ply:SteamID64() or 'null',
					points
				),
				nil -- Nothing needs to be returned
			)
		end
	)
end

function PROVIDER:SaveItem(ply, item_id, data)
	self:GiveItem(ply, item_id, data)
end

function PROVIDER:GiveItem(ply, item_id, data)
	createUser(
		ply,
		function()
			eval(
				string.format(
					[[
						r.table('users')
							.get("%s")
							.update({
								items: {
									%s: %s
								}
							})
							.run()
							.then((result) => {
								res.json(result)
							})
					]],
					ply:SteamID64() or 'null',
					item_id,
					util.TableToJSON(data)
				),
				nil -- Nothing needs to be returned
			)
		end
	)
end

function PROVIDER:TakeItem(ply, item_id)
	createUser(
		ply,
		function()
			eval(
				string.format(
					[[
						r.table('users')
							.get("%s")
							.replace(
								r.row.without({
									items: {
										'%s': true
									}
								})
							)
							.run()
							.then((result) => {
								res.json(result)
							})
					]],
					ply:SteamID64() or 'null',
					item_id
				),
				nil -- Nothing needs to be returned
			)
		end
	)
end

function PROVIDER:SetData(ply, points, items)
	eval(
		string.format(
			[[
				r.table('users').insert({
					id: "%s",
					items: %s
				}, {
					conflict: 'update'
				})
				.run()
				.then((result) => {
					res.json(result)
				})
			]],
			ply:SteamID64() or 'null',
			util.TableToJSON(items)
		),
		nil
	)
end
