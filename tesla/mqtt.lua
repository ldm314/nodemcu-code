
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
    if(DEBUGOUTPUT) then print("topic: "..topic) end
    if(topic == "pulse/"..SENSORID) and data ~= nil then
        print("pulse: "..data)
        do
            local pulse, mode, write, wdclr, OUTPUT = tonumber(data), gpio.mode, gpio.write, tmr.wdclr, gpio.OUTPUT
            mode(1,OUTPUT)
            for i = 1,pulse do
                write(1,1)
                write(1,0)
            end
            write(1,0)
        end
        
    end
    
end)

mqtt_connected = false
-- for TLS: m:connect("192.168.11.118", secure-port, 1)
mqtt_client:connect(MQTT_HOST, 1883, 0, 1,
    function(client) 
        mqtt_connected = true
        if(DEBUGOUTPUT) then print("MQTT Connected") end
        client:subscribe("pulse/"..SENSORID,0, function(client) if(DEBUGOUTPUT) then print("SUBSCRIBE: pulse/"..SENSORID) end end)
    end, 
    function(client, reason) 
        if(DEBUGOUTPUT) then print(string.format("MQTT failed: %s", reason)) end
    end
)
