-- message.lua
local module = {}
module.status = false;
module.dispatch = {}

function module.getPath(str)
  local indexOfLastSeparator = string.find(str, "/[^/]*$")
  return string.sub(str,0,indexOfLastSeparator-3),string.sub(str,indexOfLastSeparator-1,indexOfLastSeparator-1),string.sub(str,indexOfLastSeparator+1,string.len(str));
end

function module.register()  
     --module.module.m:subscribe(module.config.endpoint .. config.ID.."/#",0,function(conn) end)
     module.m:subscribe(module.config.endpoint .. module.config.ID.."/relay/#",0,function(conn) end)
end

function module.errCallback(client, reason) 
   module.m:close()
   module.status=false
   tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, module.do_mqtt_connect)
   print("mqtt unavaliable.")
end

function module.okCallback(con)
        module.register()
        module.status=true
        print("connected to mqtt broker")
        
        module.tmr = tmr.create():alarm(module.config.rate, tmr.ALARM_AUTO, module.sendMQTTData) 
        
        print("sending mqtt packets every "..module.config.rate.." ms")
 
        module.m:on("offline", function(client, topic, data)
            print("lost connection with mqtt server")
            module.m:close()
            module.tmr:unregister()
            module.tmr = nil
            module.status=false
            module.do_mqtt_connect()
        end)
        
        module.m:on("message", function(conn, topic, data)
         print("topic: "..topic)
         local path,num,cmd = module.getPath(topic)
        if data~=nil and module.dispatch[path] then
            module.dispatch[path](path,num,cmd,data)
        path,num,cmd = nil
        end
     end)
end


function module.do_mqtt_connect()
  module.status = false
  print("connecting to "..module.config.server.." @ "..module.config.port)
  module.m:connect(module.config.server, module.config.port, 0, 0, module.okCallback,module.errCallback)
end



function module.send(topic,message)
    module.m:publish(module.config.endpoint..module.config.ID.."/"..topic,message,0,0)
end


function module.start(config, sensors)
    print("configuring message subsystem")
    print(node.heap());
    module.config = config
    module.m = {}
    module.m = mqtt.Client(module.config.ID, 120)
    module.sensors = sensors
    module.do_mqtt_connect()
    module.dispatch[module.config.endpoint .. module.config.ID.."/relay"] = module.controlrelay
end

function module.controlrelay(path,num,cmd,data)
        print("getcmd topic: "..path.." num "..num.." cmd "..cmd)
        local x = relays[tonumber(num)]
        local ret = x.cmdTable[cmd](data)
        
        if(ret~=nil)then 
            print("status return: ".. ret)
            module.m:publish(path.."/"..num.."/status/return",ret,0,0)
            --print("d topic: "..path.." num "..num.." cmd "..cmd) end
            end

        x = nil
        ret = nil
end

function module.sendMQTTData()
    module.send("temperature",module.sensors.t)
    module.send("humidity",module.sensors.h)
end


return module
