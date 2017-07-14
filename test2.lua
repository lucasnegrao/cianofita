gpio.mode(8, gpio.OUTPUT)
gpio.write(8, gpio.LOW)

function main()
print("OFF");
pwm.setup(8, 50, 0)

    tmr.create():alarm(10000,tmr.ALARM_SINGLE,function()
        print("250");
        pwm.setduty(8, 250)
        tmr.create():alarm(10000,tmr.ALARM_SINGLE,function()
            print("512");
            pwm.setduty(8, 512)
            tmr.create():alarm(10000,tmr.ALARM_SINGLE,function()
                print("1024");
                pwm.setduty(8, 1023)
                tmr.create():alarm(10000,tmr.ALARM_SINGLE,function()
                    main()
                    end)
            end)
        end)
    end)
end

main(1)

--pin = 1
--gpio.mode(pin, gpio.OUTPUT)
--gpio.write(pin, gpio.HIGH)