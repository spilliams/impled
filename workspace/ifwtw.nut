/**
 * @param out   Output variable
 * @param r     Red value [0-255]
 * @param g     Green value [0-255]
 * @param b     Blue value [0-255]
 */
function Color(out, r, g, b)
{
  out.writen(r, 'b');
  out.writen(g, 'b');
  out.writen(b, 'b');
  return out;
}

/**
 * What's the significance of 85? 170?
 */
function Wheel(out, WheelPos)
{
  if (WheelPos < 85) 
  {
   return Color(out, WheelPos * 3, 255 - WheelPos * 3, 0);
  }
  else if (WheelPos < 170) 
  {
   WheelPos -= 85;
   return Color(out, 255 - WheelPos * 3, 0, WheelPos * 3);
  } else {
   WheelPos -= 170; 
   return Color(out, 0, WheelPos * 3, 255 - WheelPos * 3);
  }
}

/** Converts a hexidecimal value to an integer value? */
function hexToInteger(hex)
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

local cache = null;
local frames_count = 0;
local count = 0;
local numPixels = 1;
local writeWait = 0.1;

server.log("spi config start");
hardware.spi257.configure(SIMPLEX_TX, 15000); // Datasheet says max 25MHz
hardware.pin5.configure(DIGITAL_OUT);
hardware.pin5.write(0);    
imp.sleep(0.01);
hardware.pin5.write(1);
hardware.configure(SPI_257);
server.log("spi config end");

class LedInput extends InputPort
{
    function set(frames)
    { 
        local r = 0;
        local g = 0;
        local b = 0;
        server.log("frames received");
        frames_count = 0
        cache = [];
        foreach(frame, value in frames)
        {
            frame++;
            local out = blob(3*numPixels);   
            foreach (key, val in value)
            {
                
                r = hexToInteger(val.slice(1,3));
                g = hexToInteger(val.slice(3,5));
                b = hexToInteger(val.slice(5,7));
                //server.log(format("%i, %i, %i", r, g, b));
                out = Color(out, b, r, g);
            }
            cache.append(out);
            hardware.spi257.write(out);
            server.log(format("frame %i", count));
            count++;
            imp.sleep(writeWait);
            
        }
        server.log(format("Found %i frames", frames_count));
    }
    
    
    
}

local rainbow_count = 0;

function run_cache()
{
    
    if(cache != null)
    {  
        imp.wakeup((frames_count * writeWait)+1, run_cache);
        server.log("wake up : run_cache");
        foreach(frame,out in cache)
        {
            //server.log(typeof out);
            hardware.spi257.write(out);
            //server.log(format("cache frame %i, %i", frame, count));
            count++;
            imp.sleep(writeWait);
        }
    }
    else
    {
        imp.wakeup((256*0.0020), run_cache);
        server.log("nothing, doing a rainbow");
        for(local j=0; j < 256; j++)
        {
            local out = blob(3*numPixels);
            for (local i=0; i<numPixels; ++i) 
            {
                out = Wheel( out, ((i * 256 / numPixels) + j) % 256);   
                
            }
            hardware.spi257.write(out);
            // WS2801 datasheet says idle for 500us to latch
            imp.sleep(0.005);
        }
    }
}

// Register with the server
imp.configure("Web Frames Array", [ LedInput() ], [] );

run_cache();
// End of code.