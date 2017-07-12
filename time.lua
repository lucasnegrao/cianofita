local module = {}

module.inSync = false

function module.timeOKCallback(sec, usec, server, info)
  module.inSync = true
  module.userOKCallback()
  fd = file.open("lastGoodTime", "w+")
  if fd ~= nil then
    fd:write(rtctime.get())
    fd:close(); fd = nil
  end
end

function module.timeErrCallback(type,info)
    print("sntp sync failed with code "..type)
    module.do_sntp_connect()
end

function module.do_sntp_connect()
print("contacting NTP server @ "..module.server)
     tmr.create():alarm(2000, tmr.ALARM_SINGLE, function ()
        sntp.sync(module.server, module.timeOKCallback, module.timeErrCallback,true)
    end)
end

function module.start(server,cb,tz)
    print("setting timezone...")
    module.tz = tz
    
    print("setting to last good time...")
    fd = file.open("lastGoodTime", "r")
    if fd then
      rtctime.set(fd:read())
      fd:close(); fd = nil
    else  print("no good time available...")
    end
    
    module.server = server
    module.do_sntp_connect()
    module.userOKCallback = cb;
end

function module.getPrintable()
    if module.tz == nil or module.inSync == false then return "no time" end
    
    util = require("useful")
    hour,minute,second,month,day,year=util.getRTC(module.tz)
    util = nil
 if(module.inSync == true) then
  return string.format("%02d:%02d  %02d/%02d/%04d",hour,minute,month,day,year)
  end
end

return module
