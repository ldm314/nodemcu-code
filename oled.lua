-- OLED Display demo
-- March, 2016 
-- @kayakpete | pete@hoffswell.com
-- Hardware: 
--   ESP-12E Devkit
--   4 pin I2C OLED 128x64 Display Module
-- Connections:
--   ESP  --  OLED
--   3v3  --  VCC
--   GND  --  GND
--   D1   --  SDA
--   D2   --  SCL


function init_OLED(sda,scl) --Set up the u8glib lib
     sla = 0x3C
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
     --disp:setRot180()           -- Rotate Display if needed
end

function print_OLED(str1,str2,str3,str4)
   disp:firstPage()
   repeat
     disp:drawFrame(2,2,126,62)
     disp:drawStr(5, 5, str1)
     disp:drawStr(5, 15, str2)
     disp:drawStr(5, 25, str3)
     disp:drawStr(5, 35, str4)
   until disp:nextPage() == false
   
end