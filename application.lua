--sync with sntp
function do_sntp_sync()
    oled_rows[2] = "Fetching Time"
    draw_OLED()
    sntp.sync("0.pool.ntp.org",
      function(sec, usec, server, info)
        oled_rows[2] = "NTP Sync Success"
        draw_OLED()
      end,
      function(err,info)
        oled_rows[2] = "NTP Sync Failure"
        if(err) then
            oled_rows[3] = string.format("%i",err)
        end
        if(info) then   
            oled_rows[4] = string.format("%s",info)
        end   
        draw_OLED()
      end
    )
end

--rtc display updater, evey 500 msec
tmr.create():alarm(500, tmr.ALARM_AUTO, function(my_timer) 
    sec = rtctime.get()
    if sec > 0 then
        tm = rtctime.epoch2cal(sec - 25200) -- -7HRS
        oled_rows[6] = string.format("%04d/%02d/%02d %02d:%02d:%02d", tm["year"], tm["mon"], tm["day"], tm["hour"], tm["min"], tm["sec"])
        draw_OLED()
    end
    -- to stop timer: my_timer:unregister()
end)


do_sntp_sync() -- sync once

tmr.create():alarm(300000, tmr.ALARM_AUTO, function(timer) --every 5 min
    do_sntp_sync()
end)
