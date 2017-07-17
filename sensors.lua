--local config=require('config')

local module={}

function module.refresh(pin)
    local status, t, h = dht.read(pin)
    if (t<=0) then t=0 end
    if (h<=0) then h=0 end
   
    module.t = t
    module.h = h
    status,t,h = nil
end

return module
