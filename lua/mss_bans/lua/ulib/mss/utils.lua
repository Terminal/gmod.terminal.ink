local API_URL = 'http://127.0.0.1:8080/api/eval'
local AUTH = 'authentication'

--[[
    HTTP REST endpoint
]]--

function eval(js, callback)
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

function makeSafe(str)
	return string.Replace(str, [["]], [[\"]])
end
