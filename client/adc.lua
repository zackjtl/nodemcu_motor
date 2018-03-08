tmr.alarm(0, 300, 1, function()
    print(adc.read(0))
    end)