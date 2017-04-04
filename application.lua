dofile("oled.lua")

-- D1 D2 for i2c
sda = 1 -- SDA Pin
scl = 2 -- SCL Pin
init_OLED(sda,scl)

str1=wifi.sta.getip() 
str2="Time here"
str3="NTP Sync Pending"
str4=" "

function update_oled()
    print_OLED(str1,str2,str3,str4) 
end

--display updater, evey 5 sec
tmr.create():alarm(500, tmr.ALARM_AUTO, function(cb_timer) --every second
    sec,usec = rtctime.get()
    str2 = string.format("%i.%i",sec,usec)
    update_oled()
    -- to stop timer: cb_timer:unregister()
end)

--sync with sntp
sntp.sync("129.6.15.30",
  function(sec, usec, server, info)
    str3 = "NTP Sync Success"
  end,
  function()
    str3 = "NTP Sync Failure"
  end
)
