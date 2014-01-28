function hex2rgb(hexString) {
    local redHex = hexString.slice(0,2);
    local greenHex = hexString.slice(2,4);
    local blueHex = hexString.slice(4);
    local redInt = hex2integer(redHex);
    local greenInt = hex2integer(greenHex);
    local blueInt = hex2integer(blueHex);
    local rgb = blob(3);
    rgb.writen(redInt, 'b');
    rgb.writen(greenInt, 'b');
    rgb.writen(blueInt, 'b');
    return rgb;
}
function hex2integer(hex) {
    local result = 0;
    local shift = hex.len() * 4;
 
    // For each digit..
    for(local d=0; d<hex.len(); d++)
    {
        local digit;
 
        // Convert from ASCII Hex to integer
        if(hex[d] >= 0x61)
            digit = hex[d] - 0x57;
        else if(hex[d] >= 0x41)
             digit = hex[d] - 0x37;
        else
             digit = hex[d] - 0x30;
 
        // Accumulate digit
        shift -= 4;
        result += digit << shift;
    }
 
    return result;
}
function splitString(string, split) {
    local arr = [];
    local splitIndex = string.find(split);
    while (splitIndex != null) {
        local left = string.slice(0,splitIndex);
        local right = string.slice(splitIndex+1);
        arr.append(left);
        string = right;
        splitIndex = string.find(split);
    }
    arr.append(string);
    return arr;
}

function requestHandler(request, response) {
    server.log(request.path);
    try {
        if ("/static" == request.path) {
            
            
            local rgb = blob(3);
            if ("red" in request.query && "green" in request.query && "blue" in request.query) {
                rgb.writen(request.query.red.tointeger(), 'b');
                rgb.writen(request.query.green.tointeger(), 'b');
                rgb.writen(request.query.blue.tointeger(), 'b');
            } else if ("hex" in request.query) {
                rgb = hex2rgb(request.query.hex);
            } else {
                response.send(404, "usage: red=0&green=0&blue=0 or hex=FFFFFF");
            }
            device.send("static", rgb);
            
            
        } else if ("/cycle" == request.path) {
            
            
            local data = {colors=[], tColor=0, tTransit=0};
            
            if ("hexes" in request.query && "tColor" in request.query && "tTransit" in request.query) {
                server.log("hexes: "+ request.query.hexes);
                local hexes = splitString(request.query.hexes, ",");
                server.log(hexes.len().tostring() + " colors to process");
                for (local i=0; i<hexes.len(); i++) {
                    local hex = hexes[i].tostring();
                    server.log("processing hex "+hex);
                    local rgb = hex2rgb(hex);
                    local red = hex2integer(hex.slice(0,2));
                    local green = hex2integer(hex.slice(2,4));
                    local blue = hex2integer(hex.slice(4));
                    data.colors.append({r=red, g=green, b=blue});
                }
                data.tColor = request.query.tColor.tofloat();
                data.tTransit = request.query.tTransit.tofloat();
            } else {
                response.send(404, "usage: hexes=[FFFFFF,FFFFFF]&tColor=0&tTransit=60 (all times in seconds)");
            }
            
            device.send("cycle", data);
            
            
        } else if ("/sleep" == request.path) {
            // the imp shall stop executing code
            imp.sleep(0.005); // 5 ms
        } else {
            
            
            response.send(404, "Not Found");
            
            
        }
        // send a response back saying everything was OK.
        response.send(200, "OK");
    } catch (ex) {
        response.send(500, "Internal Server Error: " + ex);
    }
}
 
// register the HTTP handler
http.onrequest(requestHandler);
