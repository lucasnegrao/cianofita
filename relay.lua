Class = dofile("class.lc")
--dofile("schedule.lua")

--Relay.MOD_NAME="Relay"..tostring(pin)
local Relay = {} 
local Relay_mt = Class(Relay)
Class = nil


function Relay:create(pin,tz)
    self = setmetatable({}, Relay_mt)
    self.pin = tostring(pin)
    self.tz = tz
    self.cmdTable = {}
    self.cmdTable["on"] = function(data) return self:on(data) end
    self.cmdTable["off"] = function(data) return self:off(data) end
    self.cmdTable["status"] = function(data) return self:getStatus(data) end
    
    self.cmdTable["schedule"] = function(data)
        -- 18:52-19:57            
        local starth = string.sub(data,1,2);
        local startm = string.sub(data,4,5)
        local stoph = string.sub(data,7,8);
        local stopm = string.sub(data,10,12)
        self:schedule(starth,startm,stoph,stopm)
        starth,startm,stoph,stopm = nil
    end
        
    print("creating relay on pin "..tostring(self.pin))
    local fd = file.open(tostring(self.pin)..".schedule", "r")
   
    if fd then
      local data = fd:read()
      self.cmdTable["schedule"](data)
      fd:close(); fd = nil
    else
        Relay.off(self)
    end
   return self
end

function Relay:getStatus(data)
    return tostring(self.status)
end

function Relay:off(data)
   print("turn off relay pin "..self.pin)
   gpio.write(self.pin,gpio.HIGH)
   gpio.mode(self.pin,gpio.INPUT,gpio.PULLUP)
   self.status = false
   return self:getStatus()
end

function Relay:on(data)
 
   local z = tonumber(data)
   if(z~=nil) then
    if(z>0) then self:onFor(z) return end
   end
   z = nil
   
   print("turn on relay pin "..self.pin)
   gpio.mode(self.pin,gpio.OUTPUT,gpio.PULLDOWN)
   gpio.write(self.pin,gpio.LOW)
   self.status = true
   return self:getStatus()

end

function Relay:cancelSchedule()
   self.scheduled=false
   self.objCronStart:unschedule()
   self.objCronStop:unschedule()
   self.objCronStart=nil
   self.objCronStop=nil
   print("unscheduling on @"..self.startTime.." and off @"..self.stopTime);
   collectgarbage()

end


function Relay:schedule(starth,startm,stoph,stopm)
     if(self.scheduled==true) then
      self:cancelSchedule()
      self.objCronStart,self.objCronStop = nil
      self.scheduled=false
    end
    print("scheduling relay "..self.pin.." @ "..starth..":"..startm.." and off @"..stoph..":"..stopm);
    self.startTime= nil
    self.startTime= nil
    self.stopUserCb = nil
    self.startTime = starth..":"..startm
    self.stopTime = stoph..":"..stopm
    local on_hour = tonumber(starth) 
    local off_hour = tonumber(stoph)
    local on_minute = tonumber(startm)
    local off_minute = tonumber(stopm)
    
    util = dofile("useful.lua")
    local hour,minute=util.getRTC(self.tz)
    util = nil

    if ( ((hour>on_hour) and (hour < off_hour)) ) or ( (hour==on_hour) and (minute>=on_minute) and (minute<off_minute) )
        then    
            self:on()
       else
            self:off()
    end
    
    hour,minute = nil
    
    on_hour = on_hour - self.tz
    off_hour = off_hour - self.tz

    if(on_hour >= 24) then on_hour = on_hour-24 end
    if(off_hour >= 24) then off_hour = off_hour-24 end
   
    self.objCronStart = cron.schedule(startm.." "..on_hour.." * * *", function() self:on() end)
    self.objCronStop = cron.schedule(stopm.." "..off_hour.." * * *", function() self:off() end)
    
    self.scheduled = true
      
    local fd =  file.open(tostring(self.pin)..".schedule", "w")
    if fd then
      fd:write(starth..":"..startm.."?"..stoph..":"..stopm)
      fd:close()
      fd=nil
    end
end

function Relay:onFor(n)
    print("turning relay "..tostring(self.pin).." for "..tostring(n).." seconds")
    self:on()
    local cb=function() self:off() end
    tmr.create():alarm(n*1000, tmr.ALARM_SINGLE,cb)
end

return Relay
