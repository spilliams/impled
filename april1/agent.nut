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


/** LED Program table
 * restart: a boolean flag to tell the device to restart the program
 * frames: an array of rgb values (3-byte blobs)
 * cursor: an integer telling the device which frame to display
 * sleep: a float telling the device how long each frame lasts
 */

function requestHandler(request, response) {
    server.log(request.path);
    local lp = server.load();
    server.log("lp is "+lp.len().tostring() + " long.");
    try {
        if ("/reset" == request.path) { 
            server.save({restart = false, frames = [], cursor = 0, sleep = 1});
        } else if ("/one" == request.path) {
            lp.restart = true;
            lp.frames = [hex2rgb("550000"), hex2rgb("555555")];
            server.save(lp);
        } else if ("/two" == request.path) {
            lp.restart = true;
            lp.frames = [hex2rb("005500"), hex2rgb("555555")];
            server.save(lp);
        } else if ("/static" == request.path) {
            response.send(404, "not implemented");
        } else if ("/cycle" == request.path) {
            
            
            local data = {interrupt=true, command="cycle", colors=[], tColor=0, tTransit=0};
            
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
                
                lp = data;
                server.save(lp);
            } else {
                response.send(404, "usage: hexes=[FFFFFF,FFFFFF]&tColor=0&tTransit=60 (all times in seconds)");
            }
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
