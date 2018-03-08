cfg={}
cfg.ssid="jl81iot";
cfg.pwd="m94g0213";
wifi.ap.config(cfg);

cfg={}
cfg.ip="192.168.1.1";
cfg.netmask="255.255.255.0";
cfg.gatewau="192.168.1.1";
wifi.ap.setip(cfg)
wifi.setmode(wifi.SOFTAP)

str=nil
ssidTemp = nil
collectgarbage()

verticalDir = 0
horizontalDir = 0
max_speed = 1024
min_to_max_time = 1500.0
cmd_interval = 500
acc_per_ms = max_speed / min_to_max_time
acc_per_cmd = acc_per_ms * cmd_interval
--acc_per_cmd = 341

speed = 0

print("Soft AP started")
--print("Heep:(bytes)");
print("MAC:\r\nIP:"..wifi.ap.getip());

collectgarbage()

function print_vstatus()
    if (verticalDir == 0) then
        print("stop")
    elseif(verticalDir == 1) then
        print("go ahead, speed "..speed)
    elseif(verticalDir == 2) then
        print("go back, speed "..speed)
    end        
end

function increase_speed()
    if (speed < max_speed) then
        if ((speed + acc_per_cmd) > max_speed) then
            speed = max_speed
        else
            speed = speed + acc_per_cmd
        end   
    end    
end

function decrease_speed()
    if (speed > 0) then
        if (acc_per_cmd > speed) then
            speed = 0
        else
            speed = speed - acc_per_cmd
        end        
    end
end

function go_ahead()
    verticalDir = 1    
end

function go_back()
    verticalDir = 2  
end

function joystick_action(v)
    print("value "..v);
    if (v >= 700) then
        if (verticalDir == 0) then
            go_ahead()
        end                                        
        increase_speed()
    elseif (v <= 200) then
        if (verticalDir == 0) then
            go_back()         
        end
        decrease_speed()
    end
end

srv=net.createServer(net.TCP) 
srv:listen(80,function(conn) 
    conn:on("receive",function(conn, payload) 
        conn:send("<h1> Got command.</h1>")
        if (string.gmatch(payload, "adc")) then
            i = 0;
            is_adc = false
            for str in string.gmatch(payload, "%w+") do               
                if (i == 0 and str == "adc") then
                    is_adc = true                                        
                elseif (i == 1 and is_adc) then
                    joystick_action(tonumber(str))
                    print_vstatus()
                end
                i = i+1;
            end            
        end
        --conn:send("<h1> Hello, NodeMcu.</h1>")
    end) 
end)

id  = 0
sda = 1
scl = 2

-- initialize i2c, set pin1 as sda, set pin2 as scl
i2c.setup(0, sda, scl, i2c.SLOW)

tmr.alarm(1, 1000, 1, function()
    i2c.start(id)
    i2c.address(id, 0x3b, i2c.RECEIVER)
    i2cval = i2c.read(id, 1)
    i2c.stop(id)
    print("i2c: "..string.byte(i2cval))
end)

