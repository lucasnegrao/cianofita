-- file : init.lua

app = dofile("application.lua")  
tmr.create():alarm(2000,tmr.ALARM_SINGLE,app.start);   
