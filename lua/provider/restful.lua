--[[

	RESTful RethinkDB for Pointshop
	
	MIT License

	Copyright (c) 2017 Moustacheminer Server Services

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.

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
				r.table('points')
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
				r.table('points')
					.get("%s")
					.run()
					.then((result) => {
						res.json(result)
					})
			]],
			ply:SteamID64() or 'null'
		),
		function(body)
			if (body) then
				callback(
					body.points or 0,
					body.items or {}
				)
			else
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
						r.table('points')
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
						r.table('points')
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
						r.table('points')
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
						r.table('points')
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
						r.table('points')
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
				r.table('points').insert({
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
