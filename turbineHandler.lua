local objectif = 1800
 
local t = {}
local pN = peripheral.getNames()
 
b=1
 
for i,v in pairs(pN) do
  if peripheral.getType(v) == "BigReactors-Turbine" then
    t[b] = peripheral.wrap(v)
    print(v," : ",t[b]==nil)
    b = b+1
  end
end
 
local function adjust(t,oS)
  if not t.isConnected() then return false end
 
  local tS = t.getRotorSpeed()
 
  if tS == nil then error([[couldn't get RotorSpeed : adjust()]]) end
  if tS > oS then end
 
end
 
function upload(path,content)
  local path = tostring(path)
  if fs.exists(path) then fs.delete(path) end
  if not type(content) == "table" then error([[upload(): requires a table as content]]) end
  local h = fs.open(path,"w")
  h.write(textutils.serialise(content))
  h.close()
end
 
function getData(t)
  if t == nil then error([[getData(): 'turbine object' found nil]]) end
  local data = {}
  for i,v in pairs(t) do
    data[i] = v()
  end
  return data
end
 
function gFile(n)
  local path = "/turbine/data"..n
  local lF = fs.list(path)
  local tM = 0
  for i,v in pairs(lF) do
    local tV = tonumber(v)
    if tV > tM then tM = tV end
  end
  for i,v in pairs(lF) do
    if tonumber(v) <= (tM-19) then 
      local tFp = path.."/"..tostring(v)
      fs.delete(tFp)
      print("delete"..tFp)
    end
  end
  --print(textutils.serialise(lF))
  return #lF,tM
end
 
function cFile(n)
  local nF,nM = gFile(n)
  local content = getData(t[n])
  local path = tostring("turbine/data"..n.."/"..nM+1)
  upload(path,content)
end
 
function cChunk(n)
  for i=1,20 do
    cFile(n)
    sleep(1)
  end
end
