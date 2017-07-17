l = file.list();
for k,v in pairs(l) do
  print("name:"..k..", size:"..v)
end

if file.open("fan.auto", "r") then
  print(file.read())
  file.close()
end
