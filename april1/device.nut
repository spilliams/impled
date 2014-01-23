// attempt at being able to interrupt looping commands
interrupt <- false;
ready <- true;
dTime <- 0.005; // seconds

//////////////////////
// HELPER FUNCTIONS //
//////////////////////

function integer2rgb(red, green, blue) {
    local rgb = blob(3);
    rgb.writen(red, 'b');
    rgb.writen(green, 'b');
    rgb.writen(blue, 'b');
    return rgb;
}

function waitUntilReady() {
    if (ready) {
        server.log("already ready. not interrupting");
        return;
    }
    
    server.log("waiting until ready. interrupting...");
    interrupt = true;
    // the currently-running loop should catch this on the next loop
    // and when its loop exits set ready[0] to 1;
    while (!ready) {
        imp.sleep(0.01);
    }
    server.log("imp ready. ending interrupt");
    // ok, nothing running, imp is ready, so stop interrupting
    interrupt = false;
}

///////////////////////////
// LED COMMAND FUNCTIONS //
///////////////////////////

function staticRGB(rgb) {
    waitUntilReady();
    
    server.log("Static RGB: "+rgb);
    hardware.spi257.write(rgb);
}

function cycle(data) {
    // waitUntilReady();
    
    local tColor = data.tColor.tofloat();
    local tTransit = data.tTransit.tofloat();
    
    local time = 0;
    local totalTime = data.colors.len() * (data.tColor + data.tTransit);
    local previousColorIndex = 0;
    
    while (!interrupt) {
        ready = false;
        
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
        
        hardware.spi257.write(rgb);
        
        imp.sleep(dTime);
        time += dTime;
        
        // rollover
        if (time > totalTime) {
            time = 0;
        }
        
        previousColorIndex = startColorIndex;
    }
    
    ready = true;
}

///////////
// INIT! //
///////////

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

agent.on("rgb", staticRGB);
agent.on("cycle", cycle);
