
rtctime.set(1436430589, 0)

first = cron.schedule("29 * * * *", function(e)
  print("First Tick")
end)
second = cron.schedule("30 * * * *", function(e)
  print("second Tick")
end)
third = cron.schedule("31 * * * *", function(e)
  print("third Tick")
end)
second = cron.schedule("32 * * * *", function(e)
  print("forth Tick")
end)
second = cron.schedule("33 * * * *", function(e)
  print("fifth Tick")
end)
second = cron.schedule("34 * * * *", function(e)
  print("sixth Tick")
end)
second = cron.schedule("35 * * * *", function(e)
  print("seventh Tick")
end)
second = cron.schedule("36 * * * *", function(e)
  print("eigth Tick")
end)
--first:unschedule()

--first:schedule("* * * * *")