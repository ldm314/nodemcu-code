-- Connections:
--   ESP  --  OLED
--   3v3  --  VCC
--   GND  --  GND
--   D1   --  SDA
--   D2   --  SCL

oled_rows = {}
oled_rows[0] = " "
oled_rows[1] = " "
oled_rows[2] = " "
oled_rows[3] = " "
oled_rows[4] = " "
oled_rows[5] = " "


function init_OLED(sda,scl) --Set up the u8glib lib
     sla = 0x3C
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
end

function draw_OLED()
   disp:firstPage()
   repeat
     disp:drawFrame(2,2,126,62)
     disp:drawStr(5, 4, oled_rows[0])
     disp:drawStr(5, 14, oled_rows[1])
     disp:drawStr(5, 24, oled_rows[2])
     disp:drawStr(5, 34, oled_rows[3])
     disp:drawStr(5, 44, oled_rows[4])
     disp:drawStr(5, 54, oled_rows[5])
   until disp:nextPage() == false   
end

-- D1 D2 for i2c
sda = 1 -- SDA Pin
scl = 2 -- SCL Pin
init_OLED(sda,scl)
draw_OLED()