-- file : init.lua
--local do_file = "application.lua"
local do_file="maintenance.lua"
print("checking for maintenance mode status...")
    
local fd = file.open("maintenance.mode", "r")
    if fd then
      local data = fd:read()
        if (data=="true") then
            print("entering maintenance mode...")
            local maintenance = true;
            do_file="maintenance.lua"
        end    
        fd:close(); fd = nil
    end

    local app = dofile(do_file); 

    tmr.create():alarm(2000,tmr.ALARM_SINGLE,app.start);   
     