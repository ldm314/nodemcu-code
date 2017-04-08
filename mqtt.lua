
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
  oled_rows[1]=(topic .. ":" ) 
  if data ~= nil then
    oled_rows[2]=data
  end
  draw_OLED()
end)

-- for TLS: m:connect("192.168.11.118", secure-port, 1)
mqtt_client:connect("192.168.1.48", 1883, 0, 
    function(client) 
        oled_rows[1] = "MQTT Connected" 
        draw_OLED()
        -- subscribe topic with qos = 0
        client:subscribe("test/topic",0, function(client) print("mqtt subscribe success") end)
        -- publish a message with data = hello, QoS = 0, retain = 0
        client:publish("test/topic","hello from esp66",0,0, function(client) print("hello sent") end)
   end, 
    function(client, reason) 
        oled_rows[1] = string.format("MQTT failed: %s", reason) 
        draw_OLED()
    end
)