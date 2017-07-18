--based on work by breagan/ESP8266_WiFi_File_Manager @ github

local module = {}

function module.file_write(append)
        if(append==true) then
           fd = file.open(module.filedata[1], "a+")
        else 
           fd = file.open(module.filedata[1], "w+")
        end
        if(fd) then
  --          local x=2
  --          while x <= module.arraylines do
                if(module.filedata[2]~=nil) then
                print(module.filedata[2])
                    fd:write(module.filedata[2])
                end
  --               x=x+1
  --          end
            fd:close()
            fd = nil
        end
end

function module.file_do()
        if module.filedata[1] then
            local fd = file.open(module.filedata[1],"r")
            if fd then
                fd:close() 
                dofile(module.filedata[1])
            end       
        end
end

function module.file_delete()
    if module.filedata[1] then
            file.remove(module.filedata[1])
        end
end
function module.file_compile() 
        if module.filedata[1] then
            local fd = file.open(module.filedata[1],"r")
            if fd then
                fd:close() 
                fd = nil
                node.compile(module.filedata[1])
            end       
        end
end
function module.start()

    module.cmd_table = {}
    module.cmd_table["f.apd"] = function() module.file_write(true) end
    module.cmd_table["f.new"] = function() module.file_write(false) end
    module.cmd_table["s.res"] = function() node.restart() end
    module.cmd_table["f.dof"] = module.file_do
    module.cmd_table["f.del"] = module.file_delete 

end
function module.parse(payload)

    print('maintenance parser...')

    module.filedata = {}

    local separator = string.byte(payload,10)
    --print(separator)
        
    local x = 0
    local data1 = ""
    --local pattern = '[^'..string.char(separator)..']+'
    local pattern = '[^'..string.char(separator)..']+'
    
    for token in string.gmatch(payload, pattern) do
        if(x>0) then module.filedata[x] = string.sub(token,2,token:len())
        else module.filedata[x] = token
        end
        --print("token: "..module.filedata[x])
        x = x + 1
    end
    module.arraylines = x
    
    print("packet count in this load "..tostring(module.arraylines))
  
    local cmd = string.sub(module.filedata[0],5,9)
    print(module.cmd_table[cmd])
    if module.cmd_table[cmd] ~= nil then
        print("calling function "..cmd)
        module.cmd_table[cmd]()
    end
   
    payload=nil
    collectgarbage()
    return "ok"

end

return module