print("user.lua")

wifi.setmode(wifi.STATION)
wifi.sta.config("jl81iot","m94g0213")
wifi.sta.autoconnect(1)
ip = wifi.sta.getip()  
print(ip)


conn=net.createConnection(net.TCP, false) 
conn:on("receive", function(conn, pl) print(pl) end)
conn:connect(80,"192.168.1.1")
conn:send("GET / HTTP/1.1\r\nHost: www.nodemcu.com\r\n"
    .."Connection: keep-alive\r\nAccept: */*\r\n\r\n")

conn:send("adc "..100)