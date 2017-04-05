-- Connections:
--   ESP  --  OLED
--   3v3  --  VCC
--   GND  --  GND
--   D1   --  SDA
--   D2   --  SCL

oled_rows = {}
oled_rows[1] = " "
oled_rows[2] = " "
oled_rows[3] = " "
oled_rows[4] = " "
oled_rows[5] = " "
oled_rows[6] = " "


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
     --disp:drawFrame(2,2,126,62)
     disp:drawStr(5, 5, oled_rows[1])
     disp:drawStr(5, 15, oled_rows[2])
     disp:drawStr(5, 25, oled_rows[3])
     disp:drawStr(5, 35, oled_rows[4])
     disp:drawStr(5, 45, oled_rows[5])
     disp:drawStr(5, 55, oled_rows[6])
   until disp:nextPage() == false   
end

-- D1 D2 for i2c
sda = 1 -- SDA Pin
scl = 2 -- SCL Pin
init_OLED(sda,scl)
draw_OLED()