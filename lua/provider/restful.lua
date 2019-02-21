local API_URL = 'http://127.0.0.1/api/v1'
local AUTH = 'kromatic is a gay'

--[[
    HTTP REST endpoint
]]--

function fetch(endpoint, payload, callback)
  http.Post(API_URL .. endpoint, {
    payload = util.TableToJSON(payload)
  }, function(body)
    local result = util.JSONToTable(body);
    if callback then
      return callback(util.JSONToTable(body))
    end
  end , nil, {
    Authorization = AUTH
  })
end

local function createUser(ply, callback)
  print(ply:SteamID64())
  fetch(
    '/ps/create-user',
    {
      id = ply:SteamID64() or 'null'
    },
    function(body)
      callback()
    end
  )
end

function PROVIDER:GetData(ply, callback)
  fetch(
    '/ps/get-data',
    {
      id = ply:SteamID64() or 'null'
    },
    function(body)
      if (body) then
        callback(
          body.points or 0,
          body.items or {}
        )
      end
    end
  )
end

function PROVIDER:SetPoints(ply, points)
  createUser(
    ply,
    function()
      fetch(
        '/ps/set-points',
        {
          id = ply:SteamID64() or 'null',
          points = points
        },
        nil
      )
    end
  )
end

function PROVIDER:GivePoints(ply, points)
  createUser(
    ply,
    function()
      fetch(
        '/ps/give-points',
        {
          id = ply:SteamID64() or 'null',
          points = points
        },
        nil
      )
    end
  )
end

function PROVIDER:TakePoints(ply, points)
  createUser(
    ply,
    function()
      fetch(
        '/ps/take-points',
        {
          id = ply:SteamID64() or 'null',
          points = points
        },
        nil
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
      fetch(
        '/ps/give-item',
        {
          id = ply:SteamID64() or 'null',
          item = item_id,
          data = data
        },
        nil -- Nothing needs to be returned
      )
    end
  )
end

function PROVIDER:TakeItem(ply, item_id)
  createUser(
    ply,
    function()
      fetch(
        '/ps/take-item',
        {
          id = ply:SteamID64() or 'null',
          item = item_id,
        },
        nil -- Nothing needs to be returned
      )
    end
  )
end

function PROVIDER:SetData(ply, points, items)
  fetch(
    '/ps/set-data',
    {
      id = ply:SteamID64() or 'null',
      items = items
    },
    nil
  )
end
