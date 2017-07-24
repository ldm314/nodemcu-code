function split(str,pat)
  pat = pat or '%s+'
  local st, g = 1, str:gmatch("()("..pat..")")
  local function getter(segs, seps, sep, cap1, ...)
    st = sep and seps + #sep
    return str:sub(segs, (seps or 0) - 1), cap1 or sep, ...
  end
  return function() if st then return getter(st, g()) end end
end

function trim(s)
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

return function (port)
   local s = net.createServer(net.TCP, 10) -- 10 seconds client timeout
   s:listen(
      port,
      function (connection)
         -- Pretty log function.
         local function log(connection, msg, optionalMsg)
            local port, ip = connection:getpeer()
            if(optionalMsg == nil) then
               print(ip .. ":" .. port, msg)
            else
               print(ip .. ":" .. port, msg, optionalMsg)
            end
         end

         local function sendError(connection,code,string)
            local mimeType = "text/plain"
            print("send error: "..code)
            connection:send("HTTP/1.0 " .. code .. " " .. string .. "\r\nServer: wemos\r\nContent-Type: " .. mimeType .. "\r\nConnection: close\r\n\r\n")
         end

         local function sendFile(connection,text,mimeType)
            if mimeType == nil then mimeType = "text/plain" end
            buf = "HTTP/1.0 200 OK\r\nServer: wemos\r\nContent-Type: " .. mimeType .. "\r\nConnection: close\r\n\r\n"
            connection:send(buf .. text)
         end
         
         local function handleRequest(connection, req)
            collectgarbage()
            local method = req.method
            local uri = req.uri
            local fileServeFunction = nil
            print("handle request")
            if #(uri.file) > 32 then
               -- nodemcu-firmware cannot handle long filenames.
               sendError(connection,400,"Bad Request")
            else
                 if method == "GET" then
                   local fileExists = file.open(uri.file, "r")
                   file.close()
    
                   print("send file: " .. uri.file)
                   if string.match(uri.file,"lua$") or string.match(uri.file,"lc$") or not fileExists then
                      sendError(connection,404,"Not Found")
                   else
                     local fileHandle = file.open(uri.file)
                     sendFile(connection,fileHandle.read(),"text/html")
                     fileHandle.close()
                     fileHandle = nil
                   end
                 elseif method == "POST" then
                   local boundary
                   for w in string.gmatch(req.raw,"Content%-Type: multipart/form%-data; boundary=(.-)\r\n") do
                    boundary = ('--'..w):gsub('%-','%%-')
                   end
                   if boundary then
                       print("Upload file. Form boundary: "..boundary)
                       for block in split(req.raw,boundary) do
                         local data = trim(block)
                         local filename = string.match(block,"Content%-Disposition:.- filename=\"(.-)\"")
                         local file_data
                         if filename then
                            print("Write File: "..filename)
                            file_data = data:gsub(".-\r\n\r\n","")
                            file.open(filename,"w")
                            file.write(file_data)
                            file.close()
                            data = nil
                            filename = nil
                            file_data = nil
                            collectgarbage()
                            print("resarting")
                            node.restart()
                        end
                        data = nil
                        filename = nil
                        file_data = nil
                        collectgarbage()
                       end
                   end
                   sendFile(connection,"")
                 else
                   sendError(connection,405, "Method not supported")
                 end
            end
         end

         local function onReceive(connection, payload)
            collectgarbage()

            if payload:find("Content%-Length:") or bBodyMissing then
               if fullPayload then fullPayload = fullPayload .. payload else fullPayload = payload end
               if (tonumber(string.match(fullPayload, "%d+", fullPayload:find("Content%-Length:")+16)) > #fullPayload:sub(fullPayload:find("\r\n\r\n", 1, true)+4, #fullPayload)) then
                  bBodyMissing = true
                  return
               else
                  payload = fullPayload
                  fullPayload, bBodyMissing = nil
               end
            end
            collectgarbage()

            -- parse payload and decide what to serve.
            local req = dofile("httpserver-request.lc")(payload)
            log(connection, req.method, req.request)
            if req.methodIsValid and (req.method == "GET" or req.method == "POST" or req.method == "PUT") then
               handleRequest(connection, req)
            else
               sendError(connection,500,"Internal Server Error")
            end
            collectgarbage()
         end

         local function onSent(connection, payload)
            connection:close()
            collectgarbage()
         end

         local function onDisconnect(connection, payload)
             collectgarbage()
         end

         connection:on("receive", onReceive)
         connection:on("sent", onSent)
         connection:on("disconnection", onDisconnect)

      end
   )
   return s
end