os.loadAPI("/f")

local nT = 3
local t = {}
local dT = {}

-- INIT : Import images

local img = {}
tank = paintutils.loadImage("/tank")
for i=1,4 do
  img[i] = paintutils.loadImage("to_"..tostring(i))
  img[i+4] = paintutils.loadImage("t_"..tostring(i))
end
img_ti_1 = paintutils.loadImage("ti_1")
img_ti_2 = paintutils.loadImage("ti_2")

-- Define main functions

function periphs()
  p = peripheral.getNames()
  for i,v in pairs(p) do
    if peripheral.getType(v) == "modem" then
      rednet.open(v)
    end
  end
  m = peripheral.find("monitor")
  if m == nil then
    m = term.current()
    use_monitor = false
  else
    m.setTextScale(0.5)
    use_monitor = true
  end
  w,h = m.getSize()
  x3 = math.abs(w/nT)
end

function getInfos(i)
  dT[i] = {}
  rednet.broadcast("getData",i)
  e = {rednet.receive(0.1)}
  if e[2] ~= nil then
    dT[i] = textutils.unserialise(e[2])
  end
end

function setWindows()
  for i=1,nT do
    t[i] = f.addWin(m,x3*(i-1)+1,1,w/3,h)
    t[i].reset = {bg_color="black", printText = function()
      f.centerText(t[i],1,"Turbine "..i,"yellow")
    end}
    j,k = t[i].size[1],t[i].size[2]
    t[i].box = f.addWin(t[i],3,3,j-5,10)
    t[i].box.reset = {bg_color="gray",printText = function()
      f.cprint(t[i].box,1,1,"Status: ","white","gray")
      f.cprint(t[i].box,16,1,"I: ","white","gray")
      f.cprint(t[i].box,1,2,"Speed: ","white","gray")
      f.cprint(t[i].box,1,3,"Generation: ","white","gray")
      f.cprint(t[i].box,1,4,"In battery: ","white","gray")
      f.cprint(t[i].box,1,5,"Optimization: ","white","gray")
      f.cprint(t[i].box,1,6,"Tank 1: ","white","gray")
      f.cprint(t[i].box,1,7,"Tank 2: ","white","gray")
      f.cprint(t[i].box,1,8,"Input limit: ","white","gray")
      f.cprint(t[i].box,1,9,"Steam flow: ","white","gray")
      f.cprint(t[i].box,1,10,"Turbine ID: ","white","gray")
      if dT[i].getActive then
        strbox1 = "Online" cbox1 = "lime"
      else
        strbox1 = "Offline" cbox1 = "red"
      end
      if dT[i].getInductorEngaged then
        strbox2 = "Engaged" cbox2 = "lime"
      else
        strbox2 = "Disengaged" cbox2 = "red"
      end
      t[i].flow = math.floor(dT[i].getEnergyProducedLastTick) * 0.001
      t[i].stored = math.floor(dT[i].getEnergyStored)
      t[i].tk1 = dT[i].getInputAmount
      t[i].tk2 = dT[i].getOutputAmount
      f.cprint(t[i].box,9,1,strbox1,cbox1,t[i].box.reset.bg_color)
      f.centerTextRight(t[i].box,1,strbox2,cbox2,t[i].box.reset.bg_color)
      f.centerTextRight(t[i].box,2,dT[i].getRotorSpeed.." RPM","yellow",t[i].box.reset.bg_color)
      f.centerTextRight(t[i].box,3,t[i].flow.." kRF/t","yellow","gray")
      f.centerTextRight(t[i].box,4,t[i].stored.." RF","red","gray")
      f.centerTextRight(t[i].box,5,dT[i].getBladeEfficiency.." %","lightBlue","gray")
      f.centerTextRight(t[i].box,6,t[i].tk1.." mb","pink","gray")
      f.centerTextRight(t[i].box,7,t[i].tk2.." mb","pink","gray")
      f.centerTextRight(t[i].box,8,dT[i].getFluidFlowRateMax.." mb/t","lightBlue","gray")
      f.centerTextRight(t[i].box,9,dT[i].getFluidFlowRate.." mb/t","lightBlue","gray")
      f.centerTextRight(t[i].box,10,tostring(dT[i].turbineID),"yellow","gray")
      if dT[i].getFluidFlowRate ~= 0 then f.drawLine(t[i],17,h-1,28-17,"lightGray")
      else f.drawLine(t[i],17,h-1,28-17,"gray") end
    end}
    t[i].turnOn = function() rednet.broadcast("turnOn",i) end
    t[i].turnOff = function() rednet.broadcast("turnOff",i) end
    t[i].InductorOn = function() rednet.broadcast("inductorOn",i) end
    t[i].InductorOff = function() rednet.broadcast("inductorOff",i) end
    t[i].rod = function(n) nN = tonumber(n) if nN >= 2000 then nN = 200 end rednet.broadcast(nN,i) end
    t[i].b1 = f.addWin(t[i],3,14,4,1)
    t[i].b2 = f.addWin(t[i],11,14,4,1)
    t[i].b3 = f.addWin(t[i],19,14,4,1)
    t[i].b4 = f.addWin(t[i],27,14,4,1)
    t[i].b5 = f.addWin(t[i],17,h-10,3,7)
    t[i].b6 = f.addWin(t[i],28,h-10,3,7)
    t[i].b1.reset = {bg_color="lime"} t[i].b1.pulse = {bg_color="lightBlue"}
    t[i].b1.press = function() if not dT[i].getActive then t[i].b1.apply("pulse") sleep(0.2) t[i].b1.apply("reset") t[i].turnOn() end end
    t[i].b2.reset = {bg_color="red"} t[i].b2.pulse = {bg_color="lightBlue"}
    t[i].b2.press = function() if dT[i].getActive then t[i].b2.apply("pulse") sleep(0.2) t[i].b2.apply("reset") t[i].turnOff() end end
    t[i].b3.reset = {bg_color="lime"} t[i].b3.pulse = {bg_color="lightBlue"}
    t[i].b3.press = function() if not dT[i].getInductorEngaged then t[i].b3.apply("pulse") sleep(0.2) t[i].b3.apply("reset") t[i].InductorOn() end end
    t[i].b4.reset = {bg_color="red"} t[i].b4.pulse = {bg_color="lightBlue"}
    t[i].b4.press = function() if dT[i].getInductorEngaged then t[i].b4.apply("pulse") sleep(0.2) t[i].b4.apply("reset") t[i].InductorOff() end end
    t[i].b5.reset = {bg_color="gray", printText = function() for k=1,3 do f.cprint(t[i].b5,2,2*k,"v","white","gray") end end}
    t[i].b5.pulse = {bg_color="lightBlue"}
    t[i].b5.press = function(n) if dT[i].getFluidFlowRateMax > 0 then t[i].b5.apply("pulse") sleep(0.2) t[i].b5.apply("reset") t[i].rod(n) end end
    t[i].b6.reset = {bg_color="gray", printText = function() for k=1,3 do f.cprint(t[i].b6,2,2*k,"^","white","gray") end end}
    t[i].b6.pulse = {bg_color="lightBlue"}
    t[i].b6.press = function(n) if dT[i].getFluidFlowRateMax < 2000 then t[i].b6.apply("pulse") sleep(0.2) t[i].b6.apply("reset") t[i].rod(n) end end
    t[i].widg1 = f.addWin(t[i],4,h-21,10,10)
    t[i].widg1.reset = {bg_color="black"}
    t[i].tank1 = f.addWin(t[i],3,h-10,5,9)
    t[i].tank1.reset = {bg_color="black",printText = function()
      term.redirect(t[i].tank1)
      paintutils.drawImage(tank,1,1)
      f.cprint(t[i].tank1,1,9,"STEAM","black")
      local tk1 = dT[i].getInputAmount
      local h = math.floor((tonumber(tk1)/4000)*8)
      f.drawBox(t[i].tank1,2,(9-h),5,8,"lightGray")
      if not h == 0 then
        f.cprint(t[i].tank1,2,9-h,tostring(tk1/1000),"gray","lightGray")
      end
      term.redirect(error_box)
    end}
    t[i].tank2 = f.addWin(t[i],10,h-10,5,9)
    t[i].tank2.reset = {bg_color="black",printText = function()
      term.redirect(t[i].tank2)
      paintutils.drawImage(tank,1,1)
      f.cprint(t[i].tank2,1,9,"WATER","black")
      local tk2 = dT[i].getOutputAmount
      local h = math.floor((tonumber(tk2)/4000)*8)
      f.drawBox(t[i].tank2,2,(9-h),5,8,"lightBlue")
      if not h == 0 then
        f.cprint(t[i].tank2,2,9-h,tostring(tk2/1000),"gray","lightBlue")
      end
      term.redirect(error_box)
    end}
    t[i].battery = f.addWin(t[i],16,h-10,10,1)
  end
  error_box = f.addWin(m,1,h,w,2)
end

function wait()
  for j=1,4 do
    for i=1,nT do
      term.redirect(t[i].widg1)
      t[i].widg1.apply("reset")
      if dT[i].getActive then
          paintutils.drawImage(img[j+4],1,1)
      else
          paintutils.drawImage(img[j],1,1)
      end
      if dT[i] == {} then
        paintutils.drawImage(img[1],1,1)
      end
    end
    term.redirect(error_box)
    sleep(0.5)
  end
end

function main()
  while true do
    for i=1,nT do
      t[i].apply("reset")
      getInfos(i)
      if dT[i] ~= nil then
        term.redirect(t[i])
        term.setCursorPos(1,9)
        t[i].box.apply("reset")
        t[i].tank1.apply("reset")
        t[i].tank2.apply("reset")
        t[i].b1.apply("reset")
        t[i].b2.apply("reset")
        t[i].b3.apply("reset")
        t[i].b4.apply("reset")
        t[i].b5.apply("reset")
        t[i].b6.apply("reset")
      else
        f.centerText(t[i],8,"Signal lost!","red")
      end
    end
    local tFlow = 0
    for i,v in pairs(dT) do
      if v ~= nil or v ~= {} then
        tFlow = tFlow + t[i].flow
      end
    end
    f.cprint(error_box,1,1,"Total production: "..tFlow.." RF/t","red","black")
    wait()
  end
end

function buttonHandler()
  while true do
    local e = {os.pullEvent()}
    if use_monitor and e[1] == "monitor_touch" then
      local x,y = e[3],e[4]
      for i,v in pairs(t) do
        t[i].temp1 = {t[i].b5.isClicked(x,y)}
        t[i].temp2 = {t[i].b6.isClicked(x,y)}
        if t[i].b1.isClicked(x,y) then
          t[i].b1.press()
        elseif t[i].b2.isClicked(x,y) then
          t[i].b2.press()
        elseif t[i].b3.isClicked(x,y) then
          t[i].b3.press()
        elseif t[i].b4.isClicked(x,y) then
          t[i].b4.press()
        elseif t[i].temp1[1] then
          t[i].b5.press(dT[i].getFluidFlowRateMax - 10 * t[i].temp1[3]
        elseif t[i].temp2[1] then
          t[i].b6.press(dT[i].getFluidFlowRateMax + 10 * t[i].temp2[3]
        end
      end
    end
  end
end

periphs()
getInfos(1) getInfos(2) getInfos(3)
setWindows()
parallel.waitForAll(buttonHandler,main)
