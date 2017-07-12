-- file : application.lua
local module = {} 

collectgarbage()

local sensors = require("sensors")
local message = require("message")
local network = require("network")
local config = require("config")
local time = require("time")
require('relay')

local function drawScreen()

    if(tonumber(node.heap())) < 10000 then print("tick "..node.heap()) end
    
    sensors.refresh(module.dht_pin)
    module.disp:firstPage()
    repeat
        module.disp:drawStr(0, 0, "temperature "..sensors.t.."C")
        module.disp:drawStr(0, 10, "humidity "..sensors.h.."%")    
        module.disp:drawStr(0, 20,time.getPrintable())
        if(network.status==true) then 
            module.disp:drawStr(0, 40, wifi.sta.getip())
        else
            module.disp:drawStr(0, 40,  "@ " .. config.sta_cfg.ssid.."...")
        end
             if(message.status==true) then 
                module.disp:drawStr(0, 50,  "MQTT ON")
                
            end    
        --module.disp:drawStr(40, 50,  tostring(node.heap()))
                
    until module.disp:nextPage() == false
end

function module.timeOK()
  print("\ntime module started")
  print("\nregistering relays")
      module.relays=nil
      relays=nil
      module.relays = {Relay:start(1,config.timezone),Relay:start(7,config.timezone)}
      relays = module.relays
     config = nil
end

function module.networkCb()
    print("network connected")
    print("\nstarting time module...")
    time.start(config.ntp,module.timeOK,config.timezone)
    print("\nstarting message module...")
    message.start(config.mqtt,sensors)

end

function module.start()

    module.dht_pin = config.dht_pin
    print(config.name.. " - fitoplancton ecosystem. - v2\n")
    print("this is "..config.id..".\n")
    sensors.refresh(module.dht_pin)
    local sla = 0x3C
    i2c.setup(0, 2, 3, i2c.SLOW)
    module.disp = u8g.ssd1306_128x64_i2c(sla)
    module.disp:setFont(u8g.font_6x10)
    module.disp:setFontRefHeightExtendedText()
    module.disp:setDefaultForegroundColor()
    module.disp:setFontPosTop()
  
      module.disp:firstPage()
      repeat
        module.disp:drawStr(0,0,"00000000000000000000")
        module.disp:drawStr(0,10,"00000000000000000000")
        module.disp:drawStr(0,20,"00000000000000000000")
        module.disp:drawStr(0,30,"000000000000000da0ra")
        module.disp:drawStr(0,40,"00000000000000000000")
        module.disp:drawStr(0,50,"00000000000000000000")
        module.disp:drawStr(0,60,"00000000000000000000")
        module.disp:drawStr(0,70,"00000000000000000000")
      until module.disp:nextPage() == false
        
      print("connect to network...")   
      network.start(config.sta_cfg,module.networkCb) 
      tmr.create():alarm(5000,tmr.ALARM_AUTO,drawScreen)

    
  
end

return module  
