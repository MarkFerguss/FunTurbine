os.loadAPI("/f")
 
local p = peripheral.getNames()
for i,v in pairs(p) do
  if peripheral.getType(v) == "modem" then
    rednet.open(v)
  end
end
 
local nT = 3
local t = {}
 
local m = peripheral.find("monitor")
if m == nil then
  m = term.current()
  use_monitor = false
else
  m.setTextScale(0.5)
  use_monitor = true
end
 
local w,h = m.getSize()
local x3 = math.abs(w/nT)
 
tank = paintutils.loadImage("/tank")
 
for i=1,nT do
  t[i] = f.addWin(m,x3*(i-1)+1,1,w/3,h)
  t[i].reset = {bg_color="black", printText = function()
    f.centerText(t[i],1,"Turbine "..i,"yellow")
  end}
  j,k = t[i].size[1],t[i].size[2]
  t[i].box = f.addWin(t[i],3,3,j-5,10)
  t[i].b1 = f.addWin(t[i],3,14,4,1)
  t[i].b2 = f.addWin(t[i],11,14,4,1)
  t[i].box.reset = {bg_color="gray",printText = function()
    f.cprint(t[i].box,1,1,"Status: ","white","gray")
    f.cprint(t[i].box,16,1,"I: ","white","gray")
    f.cprint(t[i].box,1,2,"Speed: ","white","gray")
    f.cprint(t[i].box,1,3,"Generation: ","white","gray")
    f.cprint(t[i].box,1,4,"In battery: ","white","gray")
    f.cprint(t[i].box,1,5,"Optimization: ","white","gray")
    f.cprint(t[i].box,1,6,"Steam flow: ","white","gray")
    f.cprint(t[i].box,1,7,"Tank 1: ","white","gray")
    f.cprint(t[i].box,1,8,"Tank 2: ","white","gray")
    f.cprint(t[i].box,1,9,"Input limit: ","white","gray")
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
    local flow = math.floor(dT[i].getEnergyProducedLastTick) * 0.001
    local stored = math.floor(dT[i].getEnergyStored)
    local tk1 = tostring(dT[i].getInputAmount)
    local tk2 = tostring(dT[i].getOutputAmount)
    f.cprint(t[i].box,9,1,strbox1,cbox1,t[i].box.reset.bg_color)
    f.centerTextRight(t[i].box,1,strbox2,cbox2,t[i].box.reset.bg_color)
    f.centerTextRight(t[i].box,2,dT[i].getRotorSpeed.." RPM","yellow",t[i].box.reset.bg_color)
    f.centerTextRight(t[i].box,3,flow.." kRF/t","yellow","gray")
    f.centerTextRight(t[i].box,4,stored.." RF","red","gray")
    f.centerTextRight(t[i].box,5,dT[i].getBladeEfficiency.." %","lightBlue","gray")
    f.centerTextRight(t[i].box,6,dT[i].getFluidFlowRate.." mb/t","lightBlue","gray")
    f.centerTextRight(t[i].box,7,tk1.." mb","pink","gray")
    f.centerTextRight(t[i].box,8,tk2.." mb","pink","gray")
    f.centerTextRight(t[i].box,9,dT[i].getFluidFlowRateMax.." mb/t","lightBlue","gray")
    f.centerTextRight(t[i].box,10,tostring(dT[i].turbineID),"yellow","gray")
    local tFlow = 0
    for i,v in pairs(dT) do tFlow = tFlow + v.getEnergyProducedLastTick end
    f.cprint(error_box,1,1,"Total production: "..tFlow.." RF/t","red","black")
  end}
  t[i].b1.reset = {bg_color="lime"}
  t[i].b2.reset = {bg_color="red"}
  t[i].widg1 = f.addWin(t[i],4,h-21,10,10)
  t[i].widg1.reset = {bg_color="black"}
  t[i].tank1 = f.addWin(t[i],3,h-10,5,9)
  t[i].tank1.reset = {bg_color="black",printText = function()
    term.redirect(t[i].tank1)
    paintutils.drawImage(tank,1,1)
    f.cprint(t[i].tank1,1,9,"STEAM","black")
    local h = math.floor((tonumber(dT[i].getInputAmount)/4000)*8)
    f.drawBox(t[i].tank1,2,(9-h),5,8,"lightGray")
    f.cprint(t[i].tank1,2,9-h,h.."B","gray","lightGray")
    term.redirect(error_box)
  end}
  t[i].tank2 = f.addWin(t[i],10,h-10,5,9)
  t[i].tank2.reset = {bg_color="black",printText = function()
    term.redirect(t[i].tank2)
    paintutils.drawImage(tank,1,1)
    f.cprint(t[i].tank2,1,9,"WATER","black")
    local h = math.floor((tonumber(dT[i].getOutputAmount)/4000)*8)
    f.drawBox(t[i].tank2,2,(9-h),5,8,"lightBlue")
    f.cprint(t[i].tank2,2,9-h,h.."B","gray","lightBlue")
    term.redirect(error_box)
  end}
end
error_box = f.addWin(m,1,h,w,2)
 
local img = {}
 
for i=1,4 do
  img[i] = paintutils.loadImage("to_"..tostring(i))
  img[i+4] = paintutils.loadImage("t_"..tostring(i))
end
img_ti_1 = paintutils.loadImage("ti_1")
img_ti_2 = paintutils.loadImage("ti_2")
 
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
 
e = {}
dT = {}
 
while true do
  for i=1,nT do
    t[i].apply("reset")
    dT[i] = {}
    rednet.broadcast("getData",i)
    e = {rednet.receive(0.05)}
    if e[2] ~= nil then
      dT[i] = textutils.unserialise(e[2])
      term.redirect(t[i])
      term.setCursorPos(1,9)
      --print(e[2])
      --print(textutils.serialise(dT[i]))
      t[i].tank1.apply("reset")
      t[i].tank2.apply("reset")
      t[i].box.apply("reset")
      t[i].b1.apply("reset")
      t[i].b2.apply("reset")
    else
      f.centerText(t[i],8,"Signal lost!","red")
    end
  end
  wait()
end
