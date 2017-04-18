-- Measure temperature and post data to thingspeak.com
-- 2014 OK1CDJ
--- Tem sensor DS18B20 is conntected to GPIO0
--- 2015.01.21 sza2 temperature value concatenation bug correction


counter=0
lasttemp=-999

function bxor(a,b)
   local r = 0
   for i = 0, 31 do
      if ( a % 2 + b % 2 == 1 ) then
         r = r + 2^i
      end
      a = a / 2
      b = b / 2
   end
   return r
end

--- Get temperature from DS18B20 
function getTemp(pin)
      ow.setup(pin)
      addr = ow.reset_search(pin)
      repeat
        tmr.wdclr()
      
      if (addr ~= nil) then
        crc = ow.crc8(string.sub(addr,1,7))
        if (crc == addr:byte(8)) then
          if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
                ow.reset(pin)
                ow.select(pin, addr)
                ow.write(pin, 0x44, 1)
                tmr.delay(650000)
                present = ow.reset(pin)
                ow.select(pin, addr)
                ow.write(pin,0xBE, 1)
                data = nil
                data = string.char(ow.read(pin))
                for i = 1, 8 do
                  data = data .. string.char(ow.read(pin))
                end
                crc = ow.crc8(string.sub(data,1,8))
                if (crc == data:byte(9)) then
                   t = (data:byte(1) + data:byte(2) * 256)
                   if (t > 32768) then
                        t = t - 65536
                    --t = (bxor(t, 0xffff)) + 1
                    --t = (-1) * t
                    end
                    if (addr:byte(1) == 0x28) then
                        t = t * 625  -- DS18B20, 4 fractional bits
                    else
                        t = t * 5000 -- DS18S20, 1 fractional bit
                    end
                    lasttemp = t
                    --print("Last temp: " .. lasttemp)
                end                   
                tmr.wdclr()
          end
        end
      end
      addr = ow.search(pin)
      until(addr == nil)
end

