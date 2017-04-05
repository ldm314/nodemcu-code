--rtc display updater, evey 500 msec
tmr.create():alarm(500, tmr.ALARM_AUTO, function(cb_timer) --every second
    sec = rtctime.get()
    if sec > 0 then
        tm = rtctime.epoch2cal(sec - 25200) -- -7HRS
        oled_rows[5] = string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
        draw_OLED()
    end
    -- to stop timer: cb_timer:unregister()
end)

--sync with sntp
sntp.sync("129.6.15.30",
  function(sec, usec, server, info)
    oled_rows[2] = "NTP Sync Success"
  end,
  function(err,info)
    oled_rows[2] = "NTP Sync Failure"
    if(err) then
        oled_rows[3] = string.format("%i",err)
    end
    if(info) then   
        oled_rows[4] = string.format("%s",info)
    end   
  end
)
