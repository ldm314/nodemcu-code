-- nodemcu io index for S2 S3 S4 S5, on linknode r4
relay_gpios = {0,5,6,7}
gpio_state = { gpio.LOW, gpio.LOW, gpio.LOW, gpio.LOW }
    
if(HASRELAY) then
    for i,gpio_pin in ipairs(relay_gpios) do
        gpio.mode(gpio_pin, gpio.OUTPUT)
        gpio.write(gpio_pin, gpio.LOW)
    end
end

function toggle_relay(index)
    if(gpio_state[index] == gpio.LOW) then
        gpio_state[index] = gpio.HIGH
    else
        gpio_state[index] = gpio.LOW
    end
    if(HASRELAY) then
        gpio.write(relay_gpios[index],gpio_state[index]) 
    end
end

function relay_on(index)
    gpio_state[index] = gpio.HIGH
    if(HASRELAY) then
        gpio.write(relay_gpios[index],gpio_state[index]) 
    end
end

function relay_off(index)
    gpio_state[index] = gpio.LOW
    if(HASRELAY) then
        gpio.write(relay_gpios[index],gpio_state[index]) 
    end
end
