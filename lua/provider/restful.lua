local API_URL = 'http://127.0.0.1/api/v1'
local AUTH = 'kromatic is a gay'

--[[
    HTTP REST endpoint
]]--

local function fetch(endpoint, payload, callback)
  print('out: ' .. API_URL .. endpoint)
  http.Post(
    API_URL .. endpoint,
    {
      payload = util.TableToJSON(payload)
    },
    function(body)
      local result = util.JSONToTable(body);
      if callback then
        return callback(util.JSONToTable(body))
      end
    end,
    function(error)
      print(error)
    end,
    {
      Authorization = AUTH
    }
  )
end

local function createUser(ply, callback)
  fetch(
    '/ps/create-user',
    {
      id = ply:SteamID() or 'null'
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
      id = ply:SteamID() or 'null'
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
          id = ply:SteamID() or 'null',
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
          id = ply:SteamID() or 'null',
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
          id = ply:SteamID() or 'null',
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
          id = ply:SteamID() or 'null',
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
          id = ply:SteamID() or 'null',
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
      id = ply:SteamID() or 'null',
      items = items
    },
    nil
  )
end
