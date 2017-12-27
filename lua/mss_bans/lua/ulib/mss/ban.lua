local BAN_MESSAGE = 'You have been banned from /r/pyongyang. See https://garry.moustacheminer.com/bans'
local next = next

--[[
	Override the ULib bans system
]]--

function ULib.addBan(steamid, time, reason, name, admin)
	local unban = 0;
	local adminName = 'CONSOLE'
	local adminSteam = 'CONSOLE'
	local timestamp = os.time()

	if steamid == nil or time == nil then return end

	if name == nil then
		name = 'No name provided'
	end

	if reason == nil then
		reason = 'No reason provided'
	end

	if time != 0 then
		unban = timestamp + (time * 60)
	end

	if admin != nil && admin:IsPlayer() then
		adminName = admin:Nick()
		adminSteam = admin:SteamID()
	end

	eval(
		string.format(
			[[
				r.table('bans')
					.insert({
						id: "%s",
						name: "%s",
						reason: "%s",
						timestamp: %s,
						unban: %s,
						admin: {
							name: "%s",
							id: "%s",
							timestamp: %s
						},
						modified: null
					}, {
						conflict: (id, oldban, newban) => {
							return oldban.merge(newban.without('admin')).merge({
								modified: newban('admin')
							})
						}
					})
					.run()
					.then((result) => {
						res.json(result)
					})
			]],
			makeSafe(steamid),
			makeSafe(name),
			makeSafe(reason),
			timestamp,
			unban,
			makeSafe(adminName),
			makeSafe(adminSteam),
			timestamp
		),
		function()
			ULib.refreshBans()
		end
	)

	local ply = player.GetBySteamID(steamid)
	if ply then
		ULib.kick(ply, reason, nil, true)
	end
	RunConsoleCommand('kickid', steamid, BAN_MESSAGE)
end

function ULib.unban(steamid)
	eval(
		string.format(
			[[
				r.table('bans')
					.get("%s")
					.delete()
					.run()
					.then((result) => {
						res.json(result)
					})
			]],
			makeSafe(steamid)
		),
		function()
			ULib.refreshBans()
		end
	)
end

function ULib.refreshBans()
	eval(
		[[
			r.table('bans')
				.run()
				.then((result) => {
					res.json(result)
				})
		]],
		function(body)
			ULib.bans = {}
			-- FUCKING LUA USES 1
			if next(body) != nil then
				for i = 1, #body do
					local res = body[i]
					ban = {}
					ban.steamID = res.id
					ban.time = res.timestamp
					ban.unban = res.unban
					ban.reason = res.reason
					ban.name = res.name
					ban.admin = res.admin and res.admin.name
					ban.modified_admin = res.modified and res.modified.name
					ban.modified_time = res.modified and res.modified.timestamp
					ULib.bans[res.id] = ban
				end
			end
		end
	)
end

hook.Add( "Initialize", "mss_loadbans", ULib.refreshBans)
