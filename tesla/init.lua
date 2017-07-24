if file.exists("compile.lc") then
   dofile("compile.lc")
else
   dofile("compile.lua")
end
-- all files now are compiled...
dofile("settings.lc")

current_ip = ""

wifi.setmode(wifi.STATION)

-- print event statuses by default
wifi.sta.eventMonReg(wifi.STA_IDLE, function() print("STATION_IDLE") end)
wifi.sta.eventMonReg(wifi.STA_CONNECTING, function() print("STATION_CONNECTING") end)
wifi.sta.eventMonReg(wifi.STA_WRONGPWD, function() print("STATION_WRONG_PASSWORD") end)
wifi.sta.eventMonReg(wifi.STA_APNOTFOUND, function() print("STATION_NO_AP_FOUND") end)
wifi.sta.eventMonReg(wifi.STA_FAIL, function() print("STATION_CONNECT_FAIL") end)

-- restart if we lose connectivity
wifi.sta.eventMonReg(wifi.STA_GOTIP, function(args) 
    print("STATION_GOT_IP") 
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(args)
        print("Lost connectivity! Restarting...")
        node.restart()
    end)
end)


wifi.sta.eventMonStart()
wifi.sta.config(SSID, PASSWORD) -- default is auto connect

spinner = { '-','\\',"|",'/' }
spinner_idx = 1

print("Waiting for IP -")

function startup()

    dofile("application.lc")
end

tmr.create():alarm(500, tmr.ALARM_AUTO, function(cb_timer)
    if wifi.sta.getip() == nil then
        if spinner[spinner_idx] then
            uart.write(0,string.format("%s",spinner[spinner_idx]))
        end
        spinner_idx= spinner_idx + 1
        if spinner_idx > 4 then spinner_idx = 1 end
    else
        cb_timer:unregister()
        current_ip = wifi.sta.getip()
        if(DEBUGOUTPUT) then print("IP: "..current_ip) end
        if (dofile("web_server.lc")(81)) then
            print("server running at:")
            print("   http://" .. current_ip .. ":81")
        end
              
        if(DEBUGOUTPUT) then print("5 seconds until app boots") end
        tmr.create():alarm(5000, tmr.ALARM_SINGLE, startup)
    end
end)
