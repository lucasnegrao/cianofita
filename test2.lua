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

    print("setting to last good time...")
    fd = file.open("lastGoodTime", "r")
    if fd then
      rtctime.set(fd:read())
      fd:close(); fd = nil
    else  print("no good time available...")
    end
    
    module.server = "pool.ntp.org"
    module.do_sntp_connect()
    module.userOKCallback = cb;
