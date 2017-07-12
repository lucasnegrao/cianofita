-- file: oled.lua
local module = {}

function module.start(sda,scl) --Set up the u8glib lib
     sla = 0x3C
     i2c.setup(0, sda, scl, i2c.SLOW)
     module.disp = u8g.ssd1306_128x64_i2c(sla)
     module.disp:setFont(u8g.font_6x10)
     module.disp:setFontRefHeightExtendedText()
     module.disp:setDefaultForegroundColor()
     module.disp:setFontPosTop()
     --disp:setRot180()           -- Rotate Display if needed
end

function module.print(x,y,str)
   
   module.disp:firstPage()
   repeat
    module.disp:drawStr(0, 0, str)
    until module.disp:nextPage() == false
   
end


return module
