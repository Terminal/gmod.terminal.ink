local API_URL = 'http://127.0.0.1:8080/api'
local AUTH = 'auth'

function PROVIDER:GetData(ply, callback)
	http.Fetch(API_URL .. "/ps/" .. ply:SteamID64(), function (body)
		local result = util.JSONToTable(body)
		if next(result) == nil then
			result = {
				points = 0,
				items = {}
			}
		end
		return callback(result.points, result.items)
	end )
end

function PROVIDER:SetPoints(ply, set_points)
	http.Post(API_URL .. "/ps/" .. ply:SteamID64() .. "/setpoints", {
		points = set_points
	}, nil, nil, {
		Authorization = AUTH
	})
end

function PROVIDER:GivePoints(ply, add_points)
	http.Post(API_URL .. "/ps/" .. ply:SteamID64() .. "/addpoints", {
		points = add_points
	}, nil, nil, {
		Authorization = AUTH
	})
end

function PROVIDER:TakePoints(ply, points)
	http.Post(API_URL .. "/ps/" .. ply:SteamID64() .. "/addpoints", {
		points = 0 - add_points
	}, nil, nil, {
		Authorization = AUTH
	})
end

function PROVIDER:SaveItem(ply, item_id, data)
	self:GiveItem(ply, item_id, data)
end

function PROVIDER:GiveItem(ply, item_id, data)
	http.Post(API_URL .. "/ps/" .. ply:SteamID64() .. "/giveitem", {
		itemid = item_id,
		data = data
	}, nil, nil, {
		Authorization = AUTH
	})
end

function PROVIDER:TakeItem(ply, item_id)
	http.Post(API_URL .. "/ps/" .. ply:SteamID64() .. "/takeitem", {
		itemid = item_id
	}, nil, nil, {
		Authorization = AUTH
	})
end

function PROVIDER:SetData(ply, points, items)
	http.Post(API_URL .. "/ps/" .. ply:SteamID64(), {
		points = points,
		items = items
	}, nil, nil, {
		Authorization = AUTH
	})
end
