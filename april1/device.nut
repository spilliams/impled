function integer2rgb(red, green, blue) {
    local rgb = blob(3);
    rgb.writen(red, 'b');
    rgb.writen(green, 'b');
    rgb.writen(blue, 'b');
    return rgb;
}

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

// while (true) {
//     local lp = server.load();
//     if (lp.restart) {
//         lp.cursor = 0;
//     }
    
//     hardware.spi257.write(lp.colors[lp.cursor]);
//     lp.cursor = lp.cursor+1;
//     if (lp.cursor == lp.frames.len()) lp.cursor = 0;
//     server.save(lp);
    
//     imp.sleep(lp.sleep)
// }
