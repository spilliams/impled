// attempt at being able to interrupt looping commands
interrupt <- false;
ready <- true;
dTime <- 0.01; // seconds

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

function ombre(data) {
    waitUntilReady();
    
    server.log("rgb1: ["+data.red1+","+data.green1+","+data.blue1+"]\nrgb2: ["+data.red2+","+data.green2+","+data.blue2+"]\nt1: "+data.t1+"\nt2: "+data.t2+"\ntT: "+data.tT );
    
    local time = 0;
    local totalTime = data.t1 + data.tT + data.t2 + data.tT;
    
    local loggedT1 = false;
    local loggedTt1 = false;
    local loggedT2 = false;
    local loggedTt2 = false;
    
    while (!interrupt) {
        ready = false;
        
        if (time < data.t1) {
            
            // color 1 for t1 seconds
            
            if (!loggedT1) {
                server.log("t1. interrupt: "+interrupt);
                loggedT1 = true;
                loggedTt1 = false;
                loggedT2 = false;
                loggedTt2 = false;
            }
            hardware.spi257.write(integer2rgb(data.red1, data.green1, data.blue1));
        } else if (time < (data.t1+data.tT)) {
            
            // blend (1->2) for tT seconds
            
            if (!loggedTt1) {
                server.log("tT 1. interrupt: "+interrupt);
                loggedTt1 = true;
                loggedT1 = false;
                loggedT2 = false;
                loggedTt2 = false;
            }
            
            local timePercent = (time-data.t1)/data.tT;
            // blend colors 1 and 2
            local blendRed   = ((data.red2   - data.red1)   * timePercent) + data.red1;
            local blendGreen = ((data.green2 - data.green1) * timePercent) + data.green1;
            local blendBlue  = ((data.blue2  - data.blue1)  * timePercent) + data.blue1;
            
            hardware.spi257.write(integer2rgb(blendRed, blendGreen, blendBlue));
        } else if (time < (data.t1 + data.tT + data.t2)) {
            
            // color 2 for t2 seconds
            
            if (!loggedT2) {
                server.log("t2. interrupt: "+interrupt);
                loggedT2 = true;
                loggedT1 = false;
                loggedTt1 = false;
                loggedTt2 = false;
            }
            
            hardware.spi257.write(integer2rgb(data.red2, data.green2, data.blue2));
        } else {
            
            // blend (2->1) for tT seconds
            
            if (!loggedTt2) {
                server.log("tT 2. interrupt: "+interrupt);
                loggedTt2 = true;
                loggedT1 = false;
                loggedTt1 = false;
                loggedT2 = false;
            }
            
            local timePercent2 = (time - data.t1 - data.tT - data.t2) / data.tT;
            
            local blendRed2   = data.red2   - ((data.red2   - data.red1)   * timePercent2);
            local blendGreen2 = data.green2 - ((data.green2 - data.green1) * timePercent2);
            local blendBlue2  = data.blue2  - ((data.blue2  - data.blue1)  * timePercent2);
            
            hardware.spi257.write(integer2rgb(blendRed2, blendGreen2, blendBlue2));
        }
        
        imp.sleep(dTime);
        time += dTime;
        
        // rollover
        if (time > totalTime) {
            time = 0;
        }
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
agent.on("ombre", ombre);
