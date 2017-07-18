local module = {}
local network = dofile("network.lua")
local config = dofile("config.lua")

function module.start()
    print("free memory: "..node.heap())
    
    local fd =  file.open("maintenance.mode", "w")
    if fd then
      fd:write("false")
      fd:close()
      fd=nil
    end
    
  print("connect to network...")   
  network.start(config.sta_cfg,module.networkCb) 

end

function  module.networkCb()
    print("free memory: "..node.heap())    
    module.parser = dofile("maintenance_parser.lua")
    module.parser.start()
     --module.sv = net.createUDPSocket()
    module.sv = net.createServer(net.TCP,30);
    
    module.sv:listen(7532,function(conn) 
        print("got client, redirecting output to tcp")
        print("free memory: "..node.heap())
    
        function s_output(str)
          if(conn~=nil)
             then conn:send(str)
          end
       end
   
       node.output(s_output, 1)   
   
       conn:on("receive", function(conn, pl) 
                    print("free memory: "..node.heap())
                        --print("received: "..pl)
                    if string.sub(pl, 1, 4) == "cmd:"  then    
                        conn:send(module.parser.parse(pl))
                    else 
                    node.input(pl)    
                        
                    end
           
                    collectgarbage()
       end)
   
    conn:on("disconnection",function(c)
      conn = nil
      node.output(nil)        -- un-regist the redirect output function, output goes to serial
   end)
    end)
      print("maintenance server accepting commands @"..wifi.sta.getip().." port 7532...")
end

return module