local module = {}
local other_module= {}
module.inSync = false

function module.timeOKCallback(sec, usec, server, info)
  module.inSync = true
  
  fd = file.open("lastGoodTime", "w+")
  if fd ~= nil then
    fd:write(rtctime.get())
    fd:close(); fd = nil
  end
  module.userOKCallback()
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

    print("last sync time is "..other_module.getPrintable()) 
  
    module.server = server
    module.do_sntp_connect()
    module.userOKCallback = cb;
end

function other_module.getPrintable()
    --if module.tz == nil or module.inSync == false then return "no time" end
    
    util = dofile("useful.lc")
    hour,minute,second,month,day,year=util.getRTC(-3)--module.tz)
    util = nil
  return string.format("%02d:%02d  %02d/%02d/%04d",hour,minute,month,day,year)

end

return module,other_module
