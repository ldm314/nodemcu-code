
-- init mqtt client without logins, keepalive timer 120s
mqtt_client = mqtt.Client(SENSORID, 120)

-- init mqtt client with logins, keepalive timer 120sec
--mqtt_client = mqtt.Client("clientid", 120, "user", "password")

-- setup Last Will and Testament (optional)
-- Broker will publish a message with qos = 0, retain = 0, data = "offline" 
-- to topic "/lwt" if client don't send keepalive packet
mqtt_client:lwt("/lwt", "offline", 0, 0)

mqtt_client:on("connect", function(client) print ("connected") end)
mqtt_client:on("offline", function(client) print ("offline") end)

-- on publish message receive event
mqtt_client:on("message", function(client, topic, data) 
    --oled_rows[1]=(topic .. ":" ) 
    if data ~= nil then
        oled_rows[2]=data
    end
    draw_OLED()

    if(DEBUGOUTPUT) then print("topic: "..topic) end
    if(topic == "relay/"..SENSORID) and data ~= nil then
        print("relay: "..data)
    end
    
end)

mqtt_connected = false
-- for TLS: m:connect("192.168.11.118", secure-port, 1)
mqtt_client:connect(MQTT_HOST, 1883, 0, 1,
    function(client) 
        mqtt_connected = true
        oled_rows[2] = "MQTT Connected" 
        draw_OLED()
        if(DEBUGOUTPUT) then print("MQTT Connected") end
        -- subscribe topic with qos = 0
        if(HASTEMP) then
            client:subscribe("sensor/"..SENSORID,0, function(client) if(DEBUGOUTPUT) then print("SUBSCRIBE: sensor/"..SENSORID) end end)
        end
        if(HASRELAY) then
            client:subscribe("relay/"..SENSORID,0, function(client) print("SUBSCRIBE: relay/"..SENSORID) end)
        end
    end, 
    function(client, reason) 
        oled_rows[2] = string.format("MQTT failed: %s", reason) 
        draw_OLED()
    end
)
