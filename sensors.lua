--local config=require('config')

local module={}

function module.refresh(pin)
    local status, t, h = dht.read(pin)
    module.t = t
    module.h = h
    status,t,h = nil
end

return module
