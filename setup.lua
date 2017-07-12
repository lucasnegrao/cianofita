-- file: setup.lua
local module = {}
module.status = false

function module.start()
    oled.start(3,2)  
    oled.disp:firstPage()
    repeat
      oled.disp:drawStr(0,0,"00000000000000000000")
      oled.disp:drawStr(0,10,"00000000000000000000")
      oled.disp:drawStr(0,20,"00000000000000000000")
      oled.disp:drawStr(0,30,"000000000000000da0ra")
      oled.disp:drawStr(0,40,"00000000000000000000")
      oled.disp:drawStr(0,50,"00000000000000000000")
      oled.disp:drawStr(0,60,"00000000000000000000")
      oled.disp:drawStr(0,70,"00000000000000000000")
    until oled.disp:nextPage() == false
    app.start()
end

return module  
