//////////////////////
// HELPER FUNCTIONS //
//////////////////////

function emptyCommand() {
  return makeCommand("none",     [],      0,    true,         0, false);
}
function makeCommand(command, rgbs, sleep, restart, index, loop) {
  return {command=command,
    rgbs=rgbs,
    sleep=sleep,
    restart=restart,
    index=index,
    loop=loop
  }
}
function integer2rgb(red, green, blue) {
    local rgb = blob(3);
    rgb.writen(red, 'b');
    rgb.writen(green, 'b');
    rgb.writen(blue, 'b');
    return rgb;
}

///////////////////////
// COMMAND ITERATION //
///////////////////////

function iterate() {
    if (!iterating) server.log("starting iteration");
    
    if (command.restart) {
        command.index = 0;
        command.restart = false;
    }
    
    hardware.spi257.write(command.rgbs[command.index]);

    local newIndex = command.index + 1;
    local keepGoing = true;
    
    if (newIndex >= command.rgbs.len()) {
        if (command.loop) {
            server.log("looping");
            newIndex = 0;
        } else {
            keepGoing = false;
        }
    }
    
    if (keepGoing) {
        iterating = true;
        command.index = newIndex;
        local sleep = command.sleep;
        if (sleep < minSleep) sleep = minSleep;
        if (sleep > maxSleep) sleep = maxSleep;
        imp.wakeup(sleep, iterate);
    } else {
        server.log("ending iteration (new index was "+newIndex.tostring()+", rgbs length was "+command.rgbs.len().tostring()+", and loop was "+command.loop.tostring()+")");
    }
}

//////////////////////
// COMMAND CREATION //
//////////////////////

function staticRGB(data) {
    command = makeCommand("static", [data], 0, true, 0, false);
    
    if (!iterating) iterate();
}

function cycle(data) {
    local tColor = data.tColor.tofloat();
    local tTransit = data.tTransit.tofloat();
    
    local time = 0;
    local totalTime = data.colors.len() * (data.tColor + data.tTransit);
    
    local rgbs = [];
    while (time < totalTime) {
        local rgb;
        
        // figure out where in the cycle we are.
        // start by determining how many colors we've completed
        local startColorIndex = (time / (data.tColor + data.tTransit)).tointeger();
        local colorCompletion = (time.tofloat() - startColorIndex * (tColor + tTransit)).tofloat();
        
        if (colorCompletion < tColor) {
            local colorData = data.colors[startColorIndex];
            rgb = integer2rgb(colorData.red, colorData.green, colorData.blue);
        } else {
            local percentCompletion = ((colorCompletion - tColor) / tTransit).tofloat();
            local leftColor = data.colors[startColorIndex];
            local rightColorIndex = startColorIndex + 1;
            if (rightColorIndex >= data.colors.len()) rightColorIndex = 0;
            local rightColor = data.colors[rightColorIndex];
            
            local blendR = (rightColor.r - leftColor.r) * percentCompletion + leftColor.r;
            local blendG = (rightColor.g - leftColor.g) * percentCompletion + leftColor.g;
            local blendB = (rightColor.b - leftColor.b) * percentCompletion + leftColor.b;
            
            rgb = integer2rgb(blendR, blendG, blendB);
        }
        
        rgbs.append(rgb);
        
        imp.sleep(dTime);
        time += dTime;
    }
    command = makeCommand("cycle", rgbs, dTime, true, 0, true);
    
    if (!iterating) {
        iterate();
    }
}

///////////
// INIT! //
///////////

// manually make sure that dTime is between minSleep and maxSleep
// manually make sure minSleep < maxSleep
dTime <- 0.005;    // seconds
minSleep <- 0.001; // seconds
maxSleep <- 0.1;   // seconds
command <- emptyCommand();
iterating <- false;

server.log("spi config start");
hardware.spi257.configure(SIMPLEX_TX, 15000); // Datasheet says max 25MHz
hardware.pin5.configure(DIGITAL_OUT);
hardware.pin5.write(0);    
imp.sleep(0.01);
hardware.pin5.write(1);
hardware.configure(SPI_257);
server.log("spi config end");

hardware.spi257.write(integer2rgb(255,0,0));
imp.sleep(0.5);
hardware.spi257.write(integer2rgb(0,255,0));
imp.sleep(0.5);
hardware.spi257.write(integer2rgb(0,0,255));
imp.sleep(0.5);
hardware.spi257.write(integer2rgb(0,0,0));

agent.on("static", staticRGB);
agent.on("cycle", cycle);