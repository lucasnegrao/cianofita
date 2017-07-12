require("class")

Schedule = {}
local Schedule_mt = Class(Schedule)

function Schedule:new(name,tz)
    self = setmetatable({}, Schedule_mt)
    self.objCronStart = nil
    self.objCronStop = nil
    self.status = false
    self.scheduled=false
    self.name=name
    self.tz = tz
    return self
end

function Schedule:add(starth,startm,stoph,stopm,cbStart,cbStop)
    print("scheduling for relay on "..self.name)
 
    if(self.scheduled==true) then
      self:cancel()
      self.objCronStart,self.objCronStop = nil
      self.scheduled=false
    end
    print("scheduling on @"..starth..":"..startm.." and off @"..stoph..":"..stopm);

    --self = setmetatable({}, Schedule_mt)

    self.startTime= nil
    self.startTime= nil
    self.stopUserCb = nil
    
    self.status = false
    self.startTime = starth..":"..startm
    self.stopTime = stoph..":"..stopm
    self.startUserCb = cbStart
    self.stopUserCb = cbStop
    
    local on_hour = tonumber(starth) 
    local off_hour = tonumber(stoph)

    util = require("useful")
    
    local hour,minute=util.getRTC(self.tz)

    util = nil
    -- calculate if should be on/off on timezoned data - not ideal but it works

    if ((hour>on_hour) and (hour < off_hour)) or ((hour==on_hour) and (minute>tonumber(startm)) and (hour < off_hour)) or ((hour == off_hour) and (minute < tonumber(stopm)))
        then    
            --print("should be on")
            self:startCb()
        else
            --print("should be off")
            self:stopCb()
    end
    hour,minute = nil
    
    on_hour = on_hour - self.tz
    off_hour = off_hour - self.tz

    if(on_hour >= 24) then on_hour = on_hour-24 end
    if(off_hour >= 24) then off_hour = off_hour-24 end
   
    self.objCronStart = cron.schedule(startm.." "..on_hour.." * * *", function() self:startCb() end)
    self.objCronStop = cron.schedule(stopm.." "..off_hour.." * * *", function() self:stopCb() end)
    
    self.scheduled = true
    --on_hour = nil
    --off_hour = nil
  
   return self

end

function Schedule:cancel()
print(self.name)
print(node.heap())
   self.scheduled=false
   self.objCronStart:unschedule()
   self.objCronStop:unschedule()
   
   self.objCronStart=nil
   self.objCronStop=nil
   print("unscheduling on @"..self.startTime.." and off @"..self.stopTime);
end
   
function Schedule:startCb()
        self.status="running"
        --print("running schedule @", self.startTime)
        self.startUserCb()
end

function Schedule:stopCb()
        self.status="scheduled"
        --print("stopping schedule @", self.stopTime)
        self.stopUserCb()
end
