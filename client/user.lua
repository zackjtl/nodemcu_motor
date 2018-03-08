print("user.lua")

wifi.setmode(wifi.STATION)
wifi.sta.config("jl81iot","m94g0213")
wifi.sta.autoconnect(1)
print("connected")

function wait_get_ip()
    tmr.alarm(1, 1000, 1, function()
        print("try to get ip") 
        ip = wifi.sta.getip()  
        if (ip ~= nil) then
            print("get ip")
            run()        
            tmr.stop(1)
        end
    end)
end

function run()    
    print(ip)
    
    conn=net.createConnection(net.TCP, false) 
    conn:on("receive", function(conn, pl) print(pl) end)

    conn:on("disconnection", function(conn, data)
        Log ("disconnected")
        wait_get_ip()
    end)    
    conn:connect(80,"192.168.1.1")
    conn:send("GET / HTTP/1.1\r\nHost: www.nodemcu.com\r\n"
        .."Connection: keep-alive\r\nAccept: */*\r\n\r\n")
    
    
    tmr.alarm(2, 500, 1, function()
        --print("send msg")
        value = adc.read(0)
        print(value)
        conn:send("adc "..value)    
    end)
end    

wait_get_ip()
