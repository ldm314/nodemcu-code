local compileFile = function(f)
   if file.open(f) then
      file.close()
      node.compile(f)
      if f ~= "init.lua" then
          file.remove(f)
      end
      collectgarbage()
   end
end

local files = file.list();
for k,v in pairs(files) do
    if string.match(k,"lua$") and k ~= "init.lua" then --ends with lua
        print("Compiling: "..k.." Size: "..v)
        compileFile(k)
    else
        print("Skipping: "..k.." Size: "..v)
    end 
end

-- clean up
files = nil
compileFile = nil
collectgarbage()