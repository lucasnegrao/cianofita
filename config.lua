-- file : config.lua
local module = {}

module.name = "cianofita"
module.id = "three"

module.sta_cfg = {}  
module.sta_cfg.ssid = "peanuts"
module.sta_cfg.pwd = "idspispopd"
module.sta_cfg.auto=false

module.mqtt = {} 
module.mqtt.rate = 5000
module.mqtt.server = "192.168.5.17"
module.mqtt.port = 1883
module.mqtt.endpoint = "fitoplancton/"  

module.timezone=-3
module.ntp = "129.6.15.30"
  
module.mqtt.ID = module.id.."."..module.name

module.dht_pin = 4 

module.relay_pins = {1,5,6,7}
  
module.OLED = {}
module.OLED["SDA"] = 3;
module.OLED["SCL"] = 2;
module.relays = {}
--module.relay.pins = {1,5,6,7}
--module.relay.pins[0].schedule = 

return module  
