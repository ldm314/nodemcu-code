dofile("mqtt.lua")

function get_time_str()
    sec = rtctime.get()
    if(sec > 0) then
        tm = rtctime.epoch2cal(sec - 25200) -- -7HRS
        return string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
    else
        return false
    end
end
--sync with sntp
function do_sntp_sync()
    oled_rows[1] = "Fetching Time"
    draw_OLED()
    sntp.sync("0.pool.ntp.org",
      function(sec, usec, server, info)
        oled_rows[3] = "NTP Sync Success"
        oled_rows[4] = " "
        oled_rows[5] = " "
        draw_OLED()
      end, 
      function(err,info)
        oled_rows[3] = "NTP Sync Failure"
        if(err) then
            oled_rows[4] = string.format("%i",err)
        end
        if(info) then   
            oled_rows[5] = string.format("%s",info)
        end   
        draw_OLED()
      end
    )
end

current_temp = ""
current_humidity = ""

function read_temp()
    dht_pin = 7
    
    status, temp, humi, temp_dec, humi_dec = dht.read(dht_pin)
    if status == dht.OK then
        -- Integer firmware using this example
        current_temp = string.format("%d.%02d",math.floor(temp),temp_dec/10)
        current_humidity = string.format("%d.%02d",math.floor(humi),humi_dec/10)
        return true
    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
        return false
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
        return false
    end
end
-- sync with ntp source every 15 min
do_sntp_sync() -- sync once
tmr.create():alarm(900000, tmr.ALARM_AUTO, function(timer) --every 5 min
    do_sntp_sync()
end)

--set up timer to update clock
tmr.create():alarm(500, tmr.ALARM_AUTO, function(timer) 
    time = get_time_str()
    if(time) then
        oled_rows[6] = time
        draw_OLED()
    end
    -- to stop timer: timer:unregister()
end)

--read sensor and send message every minute
read_temp()
oled_rows[1] = current_temp .. "c  " .. current_humidity .. "%h"
draw_OLED()

tmr.create():alarm(10000, tmr.ALARM_AUTO, function(my_timer) 
    have_temp = read_temp()
    if (have_temp) then
        oled_rows[1] = current_temp .. "c  " .. current_humidity .. "%h"
        draw_OLED()
        mqtt_client:publish("sensor/"..SENSORID.."/temperature",current_temp,0,0)    
        mqtt_client:publish("sensor/"..SENSORID.."/humidity",current_humidity,0,0)    
    end    
end)