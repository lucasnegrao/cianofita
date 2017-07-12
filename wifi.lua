local module = {}

function do_wifi_connect()
   tmr.stop(1)
   tmr.stop(2)
   
   wifi.setmode(wifi.STATION);
   wifi.sta.config(config.sta_cfg)
   wifi.sta.connect()
   oled.print(0,10,"get inetz @ " .. config.sta_cfg.ssid)
  
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
        oled.print(0,0,"got ip "..wifi.sta.getip())
         --tmr.create():alarm(1000, tmr.ALARM_SINGLE, app.start)
        -- tmr.alarm(1,10 * 1000, tmr.ALARM_SINGLE, app.start)
    end)
 
    wifi.eventmon.register(wifi.eventmon.STA_DHCP_TIMEOUT,do_wifi_connect)
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,do_wifi_connect)
end

function module.start()

    wifi.setphymode(wifi.PHYMODE_B)
    do_wifi_connect();

end