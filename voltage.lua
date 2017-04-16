if adc.force_init_mode(adc.INIT_VDD33) -- sample system voltage
then
  node.restart()
  return -- don't bother continuing, the restart is scheduled
end

function get_system_volts()
    return string.format("%d", adc.readvdd33(0))
end