local API_URL = 'http://127.0.0.1/api/v1'
local AUTH = 'kromatic is a gay'

--[[
    HTTP REST endpoint
]]--

function fetch(endpoint, payload, callback)
  http.Post(API_URL .. endpoint, {
		payload = util.TableToJSON(payload)
  }, function(body)
    if callback then
      return callback(util.JSONToTable(body))
    end
  end , nil, {
    Authorization = AUTH
  })
end
