l = file.list();
for k,v in pairs(l) do
  print("name:"..k..", size:"..v)
end

if file.open("1.schedule", "r") then
  print(file.read())
  file.close()
end
