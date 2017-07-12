local module = {}

module.status=false
--local config = require("config")

local function do_wifi_connect()
   
   wifi.setmode(wifi.STATION);
   wifi.sta.config(module.config)
   wifi.sta.connect()
  
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
        module.status=true
        module.userCb()
    end)
 
    wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT,do_wifi_connect)
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,do_wifi_connect)
end

function module.start(config,cb)
    module.config = config
    module.userCb = cb
    wifi.setphymode(wifi.PHYMODE_B)
    do_wifi_connect();
end

function module.ip()
    return  wifi.sta.getip()
end

return module
