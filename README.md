# Hallow
A first-person 3D survival horror game made in Godot 4. Coded using GDScript (like Python). No combat or weapons.

## About
  HALLOW is a short-form horror game built for the StarDance Hack Club Program. Inspired by indie horror games eg, Puppet Combo games (Stay Out of the House, Nun Massacre) and Granny. This game strips survival horror down to its core of explore, find the thing, get out alive.

### Story
The player is teleported into this abandoned orphanage. Using a 1970s, retro VHS style, this game is given a vintage, spooky vibe. Though, if you're a 21st-century person, removing the VHS-filter is fine too. Traverse through the dark environment where your only source of light is your flashlight.
## How to Play
## Features & Mechanics
### Gameplay
- Explore the house and find items hidden in drawers, cabinets, and rooms.
  - A lot of items in the game, even the ones that don't have text messages that pop up, are interactable. Just press 'E' and see if they are!
  - Note: MOST doors (eg cabinets) are openable, though there are a few that do not for the moment. Hopefully, ill get these fixed in the future.
- Use items on the right objects to solve puzzles and unlock the way out.
- Something is wandering the halls. If it sees you, it will hunt you down. Break line of sight, hide, and wait for it to lose interest.
  - Note: the enemy is PRETTY fast. To escape, its good to use 'shift' and turn as many corners as possible.
  - No official hiding mechanics, BUT there are many areas where you can crouch outta sight.
- You can take 5 hits before you go down, and you have 3 lives. Lose them all and it's game over.
- Find a way out of the house to escape.

### Controls
- Movement:
  - WASD OR arrow-keys (self-explanatory) 
  - Jump: 'spacebar'
  - Sprint: 'shift' (must hold to maintain; uses stamina)
  - crouch: 'C' (must hold to maintain)
- Additional controls:
  - Interact/open/pick-up/use something on something else: 'E'
    - CRUCIAL FOR PUZZLES/DOING STUFF
  - Toggle VHS-filter: 'V'
  - Turn flashlight on/off (why would you ever turn it off but): 'F'
### Puzzles/Hints
- Note about puzzles: most of them are just 'Use X on Y, and event Z will happen.'
- Look CAREFULLY for items. Note that everything (furniture and every single piece) was put into the game manually and a lot of time has gone into this alone.
- Scroll to the bottom of this read-me for SPOILERS/EXACT LOCATIONS of some confusing things.
### Features
- Enemy AI that wanders, chases on sight, follows you around corners, and searches the area after losing you
- Item-based puzzles: place, combine, and hand over items to progress
- Interactive objects that react and talk back when you look at them
- Lives system with respawning, plus a full restart on game over
- Optional retro pixelated/VHS screen filter

### Known issues
- Some cabinets don't open
- Formatting a little janky ngl
- Some parts of the monster, to make sure it can fit in some spaces, can phase through the wall sometimes (eg arm/leg but it won't attack on accident if it can't see you)

## Built With
- Godot Engine 4.7 (Compatibility renderer, exported for Web)
- Enemy animations via Mesh2Motion
- Textures from ambientCG (CC0)
- 3D models from Sketchfab (see Credits)

## Credits
Link to credits of all assets/textures used: https://docs.google.com/document/d/1X9AERCjgSHCdoN07FJbjaegF4-3cxQnzgHTglhmSxBk/edit?usp=sharing

## !!!SPOILERS!!!
- LOOK AWAY!
- Still here? You should know where some of the main things you need to find are...
- the small coin is...
  - <details>
    <summary>▶ <b>SPOILERS!</b></summary>
    <br>
    for the bubblegum machine; 
    the coin is in the middle, left drawer of the teacher's table in the classroom.
  </details>
- the skull is...
  - <details>
      <summary>▶ <b>SPOILERS!</b></summary>
      <br>
      for the offering; the skull is though the playground at the top of the yellow slide.
    </details>
- the cake is...
  - <details>
        <summary>▶ <b>SPOILERS!</b></summary>
        <br>
        to be poisoned for the creature in the cage. The cake is in the microwave in the left corner of the kitchen as you enter.
      </details>
- the screwdriver is...
  - <details>
        <summary>▶ <b>SPOILERS!</b></summary>
        <br>
        for opening the vents. The screwdriver is located on top of the shelves in the library.
      </details>
