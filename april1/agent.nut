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
function hex2integer(hex)
{
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
            device.send("rgb", rgb);
        } else if ("/ombre" == request.path) {
            local rgb1;
            local rgb2;
            if ("hex1" in request.query && "hex2" in request.query && "t1" in request.query && "t2" in request.query && "tT" in request.query) {
                local rgb1 = hex2rgb(request.query.hex1);
                local rgb2 = hex2rgb(request.query.hex2);
            } else {
                response.send(404, "usage: hex1=FFFFFF&hex2=FFFFFF&t1=0&t2=0&tT=60 (all times in seconds)");
            }
            local hex1 = request.query.hex1;
            local red1 = hex2integer(hex1.slice(0,2));
            local green1 = hex2integer(hex1.slice(2,4));
            local blue1 = hex2integer(hex1.slice(4));
            local hex2 = request.query.hex2;
            local red2 = hex2integer(hex2.slice(0,2));
            local green2 = hex2integer(hex2.slice(2,4));
            local blue2 = hex2integer(hex2.slice(4));
            local data = {
                red1=red1,
                green1=green1,
                blue1=blue1,
                red2=red2,
                green2=green2,
                blue2=blue2,
                t1=request.query.t1.tofloat(),
                t2=request.query.t2.tofloat(),
                tT=request.query.tT.tofloat()
            };
            device.send("ombre", data);
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
