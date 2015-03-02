--be sure to use the correct LCD library. 

require "cord"
sh = require "stormsh"
Button = require "button"
LCD = require "lcd"


--[[function onconnect(state)
   if tmrhandle ~= nil then
       storm.os.cancel(tmrhandle)
       tmrhandle = nil
   end
   if state == 1 then
       storm.os.invokePeriodically(1*storm.os.SECOND, function()
           tmrhandle = storm.bl.notify(char_handle, 
              string.format("Time: %d", storm.os.now(storm.os.SHIFT_16)))
       end)
   end
end]]--

entries = {}


-- gets the number of k/v pairs in a table
function tablelength(T)
  count = 0
  for _ in pairs(T) do count = count + 1 end
  print (count)
  return count
end


function onconnect(state)
   print("connection status: "..state)
end


storm.bl.enable("unused", onconnect, function()
   print("ready!")
   local svc_handle = storm.bl.addservice(0x1337)
   char_handle = storm.bl.addcharacteristic(svc_handle, 0x1338, function(x)
        print ("received: ",x)
  table.insert(entries, x)
  table.foreach(entries, print)
  -- update tablelength count
  tablelength(entries)
   end)
end)

------------LCD display code-------------------
function disp_lcd(idx)
  local v1 = tostring(idx)
  local v2 = entries[idx]
  write_to_lcd(v1, v2)
end

function lcd_setup()
    lcd = LCD.new(storm.i2c.EXT, 0x7c, storm.i2c.EXT, 0xc4)
end

function write_to_lcd(value1, value2)
    cord.new(function ()
        lcd.init(2, 1)
        lcd.writeString(value1)
        lcd.setBacklight(150, 50, 220)
        if value2 ~= nil then
          lcd.setCursor(1, 0)
          lcd.writeString(value2)
        end
    end)
end


function start()
  b1 = Button:new("D9")
  b2 = Button:new("D10")
  -- b3 = Button:new("D11")

  -- --do I need to declare table_length local?
  -- table_length = tablelength(entries)

  -- print (table_length)

  -- b3:whenever("FALLING", function()
  --   invoke_bool(curr_count)
  -- end)
  
  local curr_count = 0

  b2:whenever("FALLING", function()   
    curr_count = curr_count + 1
    if curr_count > count then curr_count = 1 end
    disp_lcd(curr_count)
  end)

  b1:whenever("FALLING", function()
    curr_count = curr_count - 1
    if curr_count < 1 then curr_count = count end
    disp_lcd(curr_count)
  end)
end

lcd_setup()
start()
cord.enter_loop()
