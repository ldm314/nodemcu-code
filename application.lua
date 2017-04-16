dofile("mqtt.lua")

current_time = ""
current_temp = ""
current_humidity = ""

function get_time_str()
    sec = rtctime.get()
    if(sec > 0) then
        tm = rtctime.epoch2cal(sec - 25200) -- -7HRS
        current_time = string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
        return current_time
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

function read_temp()
    if(HASDS18B20) then
        getTemp(DS18B20_PIN) -- on pin D2
        t1 = lasttemp / 10000
        t2 = (lasttemp >= 0 and lasttemp % 10000) or (10000 - lasttemp % 10000)
        current_temp = t1 .. "."..string.format("%04d", t2)
        if(DEBUGOUTPUT) then print(current_temp) end
        return true
    else
        dht_pin = 7
        
        status, temp, humi, temp_dec, humi_dec = dht.read(dht_pin)
        if status == dht.OK then
            -- Integer firmware using this example
            current_temp = string.format("%d.%02d",math.floor(temp),temp_dec/10)
            current_humidity = string.format("%d.%02d",math.floor(humi),humi_dec/10)
            print("temp: "..current_temp.." humidity: "..current_humidity.." time: "..current_time)
            return true
        elseif status == dht.ERROR_CHECKSUM then
            print( "DHT Checksum error." )
            return false
        elseif status == dht.ERROR_TIMEOUT then
            print( "DHT timed out." )
            return false
        end
    end
end
-- sync with ntp source every 15 min
if(NTPSYNC) then
    do_sntp_sync() -- sync once
    tmr.create():alarm(900000, tmr.ALARM_AUTO, function(timer) --every 5 min
        do_sntp_sync()
    end)
end
--set up timer to update clock if we have a screen.
if(HASOLED) then
    tmr.create():alarm(500, tmr.ALARM_AUTO, function(timer) 
        time = get_time_str()
        if(time) then
            oled_rows[6] = time
            draw_OLED()
        end
        -- to stop timer: timer:unregister()
    end)
end

publish_count = 0
expected_count = 0
function read_and_publish_sensors()
    publish_count = 0
    expecteD_count = 0
    if(HASVOLTAGE) then
        volts = get_system_volts()
        mqtt_client:publish("sensor/"..SENSORID.."/voltage",volts,0,0,function() publish_count = publish_count + 1 end)
        expected_count = expected_count + 1
        if(DEBUGOUTPUT) then
            print(volts.."mV")
        end
    end
    
    if(HASTEMP) then
        if(read_temp()) then
            if(HASOLED) then
                oled_rows[1] = current_temp .. "c  " .. current_humidity .. "%h"
                draw_OLED()
            end
            --wait for mqtt to connect and then publish
            if(current_humidity ~= "") then
                mqtt_client:publish("sensor/"..SENSORID.."/humidity",current_humidity,0,0,function() publish_count = publish_count + 1 end)
                expected_count = expected_count + 1
            end
            mqtt_client:publish("sensor/"..SENSORID.."/temperature",current_temp,0,0,function() publish_count = publish_count + 1 end)
            expected_count = expected_count + 1
        end
    end
end

-- wait for mqtt to connect and then take the readings
tmr.create():alarm(500, tmr.ALARM_AUTO, function(timer) 
    if(mqtt_connected) then
        timer:unregister()
        read_and_publish_sensors()
        if(DEBUGOUTPUT) then print "Waiting for mqtt to finish" end
        tmr.create():alarm(100, tmr.ALARM_AUTO, function(timer1) -- wait for success
            if expected_count ~= 0 and expected_count == publish_count then
                timer1:unregister()
                if(DEEPSLEEP) then
                    if(DEBUGOUTPUT) then print "Deep sleep. Goodnight." end
                    node.dsleep(120000000) -- microseconds, 2min
                else
                    if(DEBUGOUTPUT) then print "Waiting until next reading" end
                    tmr.create():alarm(120000, tmr.ALARM_AUTO, function(timer2)  --every 2 min
                        read_and_publish_sensors()
                    end)
                end
            end
        end)
    end
end)


--read sensor and send message every minute
if(HASRELAY and false) then
    -- lightshow for now
    tmr.create():alarm(500, tmr.ALARM_AUTO, function(timer)
        toggle_relay(1)
    end)    
    tmr.create():alarm(300, tmr.ALARM_AUTO, function(timer)
        toggle_relay(2)
    end)    
    tmr.create():alarm(200, tmr.ALARM_AUTO, function(timer)
        toggle_relay(3)
    end)    
    tmr.create():alarm(330, tmr.ALARM_AUTO, function(timer)
        toggle_relay(4)
    end)    
end


