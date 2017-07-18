-- fan.lua
module = {}

function module.set(data)
            print(data)
       if (string.sub(data,1,1)=='A') then
            local max = tonumber(string.sub(data,3,4))
            local min = tonumber(string.sub(data,6,7))

            module.setAuto(tonumber(max),tonumber(min))
       elseif (string.sub(data,1,1)=='M') then
            local set = string.sub(data,3,6)
            print("fan manual @ "..set);
            module.auto = false
            if set == nil then return end
             if not (module.tmr==nil) then
                module.tmr:unregister() end
            if(tonumber(set) >= 0 and tonumber(set) <1024) then
                module.speed = tonumber(set)
                pwm.setduty(module.pin, tonumber(set))
            else print("received manual @ wrong range - min=0, max=1023") end
       end
end

function module.start(pin,max_t,min_t,auto)
    module.pin = pin
    module.auto = auto
    module.speed = 0
    module.tmr = nil
    
    gpio.mode(module.pin, gpio.OUTPUT)
    gpio.write(module.pin, gpio.LOW)
    pwm.setup(module.pin, 50, 0)

    if(module.auto==true) then
        
        local fd =  file.open("fan.auto", "r")
        
        if fd then
          local data = fd:read()
          if(data) then
           max_t = tonumber(string.sub(data,3,4))
           min_t = tonumber(string.sub(data,6,7))
          end
          fd:close(); fd = nil
        end
        
        module.setAuto(max_t,min_t)
    end
end

function module.setAuto(max_in,min_in)
    if(max_in == nil or min_in == nil) then return end
    print("setting fan to automode high: @"..max_in.." low @"..min_in);
    module.max = max_in;
    module.min = min_in
    module.auto = true
    if(module.tmr~=nil) then
        module.tmr:unregister()
        module.tmr = nil end
    module.tmr = tmr.create()
    module.tmr:alarm(10000, tmr.ALARM_AUTO, module.runAuto)

    local fd =  file.open("fan.auto", "w")
    if fd then
      fd:write("A("..string.format( "%02d", min_in)..","..string.format( "%02d", max_in)..")")
      fd:close()
      fd=nil
    end
end

function module.runAuto(max_in,min_in)
    if(module.max==nil or module.min==nil) then
        print("you have to call start(pin,max,min) first!");
        return
    end
    
    local max_out = 1023
    local min_out = 250

    local slope = (max_out - min_out) / (module.max - module.min)
    local fanControl = min_out + slope * (sensors.t - module.min)
    if fanControl > max_out then fanControl = max_out end
    if fanControl < min_out then fanControl = min_out end

    pwm.setduty(module.pin, fanControl)
 
    module.speed = fanControl
    fanControl,max_out,min_out,max_in,min_in,slope = nil
end

return module
