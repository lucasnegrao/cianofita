-- file : application.lua
local module = {} 

local sensors = dofile("sensors.lc")
local message = dofile("message.lua")
local config = dofile("config.lua")
local time,time_useful = dofile("time.lua")
local network = dofile("network.lua")

local function controlFan()
    local max_out = 1024
    local min_out = 250
    local max_in = 40
    local min_in = 15

    local slope = (max_out - min_out) / (max_in - min_in)
    local fanControl = min_out + slope * (sensors.t - min_in)
    if fanControl > max_out then fanControl = max_out end
    if fanControl < min_out then fanControl = min_out end
    pwm.setduty(8, fanControl)
 
    module.fanSpeed = fanControl
    fanControl,max_out,min_out,max_in,min_in,slope = nil

end
    
local function drawScreen()

    if(tonumber(node.heap())) < 6*1024 then print("mem under 6kb "..node.heap()) end
    
    sensors.refresh(module.dht_pin)
    controlFan()
    
    module.disp:firstPage()
    repeat
        module.disp:drawStr(0, 0, "temperature "..sensors.t.."C")
        module.disp:drawStr(0, 10, "humidity "..sensors.h.."%")    
        module.disp:drawStr(0, 20,time_useful.getPrintable())
        if(network.status==true) then 
            module.disp:drawStr(0, 40, wifi.sta.getip())
        else
            module.disp:drawStr(0, 40,  "@ " .. config.sta_cfg.ssid.."...")
        end
             if(message.status==true) then 
                module.disp:drawStr(50, 50,  "mqtt ON")
                
            end    
        module.disp:drawStr(0, 50, "fan @"..tostring(module.fanSpeed))
                
    until module.disp:nextPage() == false
end


function module.timeOK()
    print("\ntime module started")
    print("time is "..time_useful.getPrintable()) 
    print("\nregistering relays")
    module.relays={}
    Relay = dofile('relay.lua')
    --time = nil
    module.registerRelays(module.relaysCallback)
 end

function module.networkCb()
    print("network connected")
    print("\nstarting time module...")
    time.start(config.ntp,module.timeOK,config.timezone)
end

function module.registerRelays(cb)
tmr.create():alarm(2000,tmr.ALARM_SINGLE,function()
    if config.relay_pins[#config.relay_pins]~=nil then
        local relay = Relay:create(config.relay_pins[#config.relay_pins],config.timezone)
        table.insert(module.relays, relay)
        relay = nil
        table.remove(config.relay_pins,#config.relay_pins)
        module.registerRelays(cb)
    else cb()
    end
end)
end

function module.relaysCallback()
    print("relays registered")

    print("\nstarting message module...")
    message.start(config.mqtt,sensors)
   
    Relay = nil
    config = nil
    relays = module.relays
end

function module.start()

    print(config.name.. " - fitoplancton ecosystem. - v2\n")
    print("this is "..config.id..".\n")
    
    module.dht_pin = config.dht_pin
    sensors.refresh(module.dht_pin)
    
    local sla = 0x3C
    i2c.setup(0, config.OLED.SDA, config.OLED.SCL, i2c.SLOW)
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

      print("initalizing fan control...")   
      
      gpio.mode(8, gpio.OUTPUT)
      gpio.write(8, gpio.LOW)
      pwm.setup(8, 50, 0)

    collectgarbage()
 end

return module  
