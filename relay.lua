require("class")
require("schedule")
Relay = {}
local Relay_mt = Class(Relay)

function Relay:start(pin,tz)
    self = setmetatable({}, Relay_mt)
    self.pin = pin
    self.scheduleObj = Schedule:new(self.pin,tz)
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
        
    print("creating relay on pin "..self.pin)
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
   local z = tonumber(data)
   if(z~=nil) then
    if(z>0) then self:offFor(z) return end
   end
   z = nil
   gpio.write(self.pin,gpio.HIGH)
   gpio.mode(self.pin,gpio.INPUT,gpio.PULLUP)
   self.status = false
   return self:getStatus()
end

function Relay:on(data)
    print("turn on relay pin "..self.pin)
   local z = tonumber(data)
   if(z~=nil) then
    if(z>0) then self:onFor(z) return end
   end
   z = nil
   gpio.mode(self.pin,gpio.OUTPUT,gpio.PULLDOWN)
   gpio.write(self.pin,gpio.LOW)
   self.status = true
   return self:getStatus()

end

function Relay:schedule(starth,startm,stoph,stopm)
      self.scheduleObj:add(starth,startm,stoph,stopm, 
      function()
        print("relay "..tostring(self.pin).." running scheduled action self.on()")
        self:on()
        end,
      function()
      print("relay "..tostring(self.pin).." stopped scheduled action self.off()")
      self:off()
      end
      )

    local fd =  file.open(tostring(self.pin)..".schedule", "w")
    if fd then
      fd:write(starth..":"..startm.."?"..stoph..":"..stopm)
      fd:close()
      fd=nil
    end
end

function Relay:onFor(n)
    self:on()
    print("turning relay "..tostring(self.pin).." for "..tostring(n).." seconds")
    --local timer = require('timer_min')
    local cb=function() self:off() end
   tmr.create():alarm(n*1000, tmr.ALARM_SINGLE,cb)
    --timer.setTimeout(cb, sec*1000)
end

function Relay:offFor(n)
    self:off()
    print("turning relay "..tostring(self.pin).." off for "..tostring(n).." seconds")
    --local timer = require('timer_min')
    local cb=function() self:on() end
   tmr.create():alarm(n*1000, tmr.ALARM_SINGLE,cb)
    --timer.setTimeout(cb, sec*1000)
end

--return class
