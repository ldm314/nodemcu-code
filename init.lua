dofile("credentials.lua")
dofile("oled.lua")
dofile("relay.lua")
dofile("ds18b20.lua")
if(HASVOLTAGE) then -- may cause a restart the first time if it has to change modes
  dofile("voltage.lua")
end

current_ip = ""

function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        oled_rows[2] = " "
        oled_rows[3] = " "
        draw_OLED()
        file.close("init.lua")
        -- the actual application is stored in 'application.lua'
        dofile("application.lua")
    end
end

wifi.setmode(wifi.STATION)
wifi.sta.config(SSID, PASSWORD)

spinner = { '-','\\',"|",'/' }
spinner_idx = 1

tmr.create():alarm(500, tmr.ALARM_AUTO, function(cb_timer)
    if wifi.sta.getip() == nil then
        if spinner[spinner_idx] then
            oled_rows[1] = string.format("Waiting for IP %s",spinner[spinner_idx])
            draw_OLED()
        end
        spinner_idx= spinner_idx + 1
        if spinner_idx > 4 then spinner_idx = 1 end
    else
        cb_timer:unregister()
        current_ip = wifi.sta.getip()
        oled_rows[1] = current_ip

        if(DEBUGOUTPUT) then print("IP: "..current_ip) end
        
        oled_rows[2] = "Waiting 2 seconds"
        oled_rows[3] = "then starting app"
        draw_OLED()
        if(DEBUGOUTPUT) then print("2 seconds until app boots") end
        tmr.create():alarm(2000, tmr.ALARM_SINGLE, startup)
    end
end)
