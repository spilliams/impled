#What have I done so far?

- Imp's Getting Started "Hello World" (blink an LED)
- Imp's Getting Started "Agents" (control an LED through the Internet)
- Use IFTTT to control a digital LED (on or off, single color) using a [webhook middleware](https://github.com/captn3m0/ifttt-webhook) deployed on Heroku (same device & agent code as "Agents")
    1. Device code is same as "Agents"
    2. Agent code is same as "Agents"
    3. install instance of [webhook middleware](https://github.com/captn3m0/ifttt-webhook) on Heroku
    4. set up new IFTTT recipe, such that new tweets with hashtag will trigger wordpress post, with `<agent url>{{TextNoHash  tag}}` in body.
- starting with base system of last point, added spi setup and a block in the agent code to parse red, green and blue and pass them to the device code. added method in device code to write input directly to spi.
    
#What's the next step?

IFTTT is slow (~15 minutes, they say. 13.5 minutes for test #1). Replace that layer, perhaps with a different heroku instance (with scheduler?). This means writing my own adapters like IFTTT has, but maybe that's ok?

1. Try other IFTTT channels, see if any are more responsive
2. Install an XMPP server on Heroku to accept GTalk messages
3. research iMessage server so I can text the thing?
4. custom heroku endpoint to command Imp

idea: redirect all GET requests to agent to heroku instance with Imp's id as param
so GET @ https://agent.electricimp.com/GY_KsyEb5KdR redirects to
http://impled.herokuapp.com/?imp=GY_KsyEb5KdR
Heroku app will post back to agent.
POSTs at agent will execute the params then GET heroku again

But any web portal will someday be used to control many Imps at once? Or one imp powering a whole strand of LEDs? I'm not sure yet.

Multiple Imps (cons):
- get all Imps on the network
- inputting April IDs
- arrange cubes online as they're arranged in real life
- more expensive per-cube

Multiple LEDs (cons):
- configuring each cube as a "straight" or "corner"
- more difficult to have multiple or sparse grids

##DSL for LED commands

- /static?red=N&green=N&blue=N
- /ombre?red1=N&green1=N&blue1=N&red2=N&green2=N&blue2=N&time1=0&time2=0&travelTime=60
- /blink?red=N&green=N&blue=N&on=1&off=1 (equivalent to ombre with color2=black&time1=1&time2=1&travelTime=0)

do we really have to specify color as red&green&blue? would it be simpler to pass color as a bit blob? Probs not...extra parsing. Leave it for now and work on more pressing matters.

#oh shit naming schemes

- Imp is the thing that drives an LED (or possibly many LEDs)
- April is the thing that connects Imp to LED(s). April is a little girl who befriends the Imp and helps him complete tasks!
- Demon sleeps mostly, but he wakes up when something happens, and he commands Imps.
- Therefore, any app setting up "recipes" across "channels" will be a Demon Controller, or Satan.