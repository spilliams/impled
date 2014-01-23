#PixelGrid

A grid of modular LED pixels that responds to its environment.

Each cube is roughly 2" to a side.

![pixel cube brainstorm](http://f.cl.ly/items/2l0y2R2K043T2S0J231d/2013-10-25%2013.39.25.jpg)

##Hardware

###Standard Cube Construction

1. A sturdy, lightweight frame makes construction a breeze. The frame is grounded, forming half of the power circuit.
2. Rear and side panels are inserted into the frame. The rear panel has a cutout for the Imp card. All panels have strong neodymium magnets. Panels may be inserted in either direction to optimize the interactions of magnets with those of adjacent cubes.
3. The "guts" subassembly is inserted. This consists of
   1. the magnet contact. This contact is charged at 3.3v, and touches all 5 magnets. It is made of a non-magnetic material and therefore doesn't care which direction the magnetic current is flowing.
   2. the Imp breakout board. This board negotiates power to and from the frame of the cube, as well as signal to the LED
   3. a bright LED
4. The front window is either clear or diffuse plastic, and friction-fits onto the frame.
5. The [Electric Imp](http://electricimp.com/) is inserted and flashed.

###Power Cord

The Power cord ends in a plate with a magnet in it surrounded by a metal rim. It attaches to the Standard Cube in order to power the whole grid. The other end is a standard USB connector. The Power cord comes with a USB-Edison adapter. Internal circuits at the Cube end of the cord make sure that a clean, stable source of 3.3V is available to the cube grid.

###IO Unit

The IO Unit is 1/3 the height of a Standard Cube, and contains no LED. It does contain 2 cameras (visible light and IR) and microphone however, so that the grid may react to sights and sounds nearby!

Using more than one IO Cube presents interesting applications for responding to motion in 3D!

###Sensor Cube

The Sensor Cube is Standard-sized, and contains a buttload of sensors: thermometer, barometer, moisture, (list in progress).

Though it has the same frame structure as the Standard Cube (meaning it can be powered by the grid) it is not necessarily meant to be attached to the grid. Purchase of a Sensor Cube will include a Power cord.

##Software

Software updates may be applied to the Imps via their web service.

Various modules will be pre-loaded into the software suite, and there will be a simple interface for swtiching between them.

There will also be a way for users to upload their own modules.

Since the hardware cannot tell how the pixels are arranged, the user will have to input that information.

###Example modules

- Equalizer. Lights up cubes to the beat of the music.
- Ombre. Rotates through colors.
- Pong. A ball of light bounces around the confines of the grid.
- Activity Monitor. lights certain cubes based on the level of movement in the room.
- Calendar. Displays a simple calendar, where each day is represented by a color based on the events on that day (more events from my work calendar = red, more events from home calendar = green, etc). Past days are dimmer than others.
- Notification Center. Each cube responds to something on the internet, like an email account or a twitter feed. This should be done through [IFTTT](http://ifttt.com)
- voice-activated scoreboard (ie it would respond to "10 points for gryffindor!")
- mobile app direct control: a mobile app will show the grid and allow user to individually set cubes to certain colors.
- productivity timer. this would either be a cube with a button panel or it would talk to some online timer (ie Harvest)

##Purchasing

Cubes will be offered at a sliding scale based on volume, with breakpoints at (for instance) 5, 15, and 25.

Standard Cube price is expected to be somewhere in the $100-$200 range.

Software is all [FOSS](http://en.wikipedia.org/wiki/Free_and_open-source_software), and will be for all time. This includes the Imp software, any custom APIs for uploading new modules and any mobile apps for controlling the Imps.

##Future

###Speaker Cube

- includes LED
- front panel is color mesh fabric

###Battery Cube

Battery Cube is just like Standard Cube but with two key differences:

- it contains an internal, rechargable battery
- a switch on the rear panel turns the cube on and off

The battery may be charged by attaching a Power Cord

[3.7V Lipoly battery](http://www.adafruit.com/products/1570)  
[Micro Lipo Charger](http://www.adafruit.com/products/1304)

Or maybe there's an [inductive charging coil](http://www.adafruit.com/products/1407)? (And corresponding Charging Plate)

###Touch Panel

Touch Panel replaces the normal front panel with a nice actuator, turning the cube into a light-up button!

###"Retina"

Single LED is replaced with grid of tiny LEDs, effectively increasing the resolution of the cube.

Perhaps the light inside the cube is plug-n-play, so users can bundle any light with any Standard Cube.

###Panel options

More front, side and rear panel options. Things like finish, color, transparency.

###Remote

A Remote Unit is the same size as the IO Unit, and contains at least four IR diodes. These are meant to communicate to nearby IO Units, performing actions based on software settings.

###Power Options

Other cubes / units to generate power from difference sources

- solar
- turbine
- handcrank
- potato / banana-clip

##Work-in-progress

let's talk numbers. Assuming initial batch size of 100 cubes-worth:

[Electric Imp](http://www.adafruit.com/products/1129): $23.96  
[Imp Breakout board](http://www.adafruit.com/products/1130): $10.00  
[LED](http://www.adafruit.com/products/738): $1.60 (4 strands of 25 at $39.95 per strand, divided by 25)  
[Magnets](http://www.kjmagnetics.com/proddetail.asp?prod=D61) (qty 5): $1.85 (note that the actual magnets used may be a slightly different model, but this price is a good ballpark)  
Total for guts: $37.41.

[Frame](http://www.grainger.com/Grainger/Flat-Stock-2FAB6?Pid=search): $6.8475*  
[clear front panel](http://www.mcmaster.com/#8574k55/=p35azi): $0.4504*  
[diffuse front panel](http://www.mcmaster.com/#8742k435/=p35c04): $0.2825*  
[rear panel](http://www.mcmaster.com/#87115k114/=p358u5): $0.6624*  
[side panels](http://www.mcmaster.com/#87115k114/=p358u5): $2.6496*  
Internal Skeleton (magnet contacts, Imp & LED brackets):  ?
Total for skeleton & skin: $10.90

Total for 1 Standard Cube: $37.41 + $10.90 = $48.31

    * (does not include machining costs)

Yikes! And that's just parts. Presumably the labor and machining all have a price too! And we want to make some kind of profit. And we have to consider packaging and shipping! $150 per pixel is prohibitive. I was thinking more like $45. :P

But, for some comparison, check out the Philips Hue. Three-bulb kit for $200. Single bulb for $60. That math doesn't seem quite right at first, but consider that the kit comes with the base station.