6:26 TrashBoatAhoy: oh that was random chance man, i grepped for "level|map|stage" through alephone source code
6:26 TrashBoatAhoy: and then i just went from there
6:27 TrashBoatAhoy: well, it's actually kinda easy with a static binary
6:28 TrashBoatAhoy: oh i mean that's a whole topic
6:28 TrashBoatAhoy: but you don't need to do that with this
6:30 TrashBoatAhoy: because it's static you can just use debuggers while the game is running, and a little prerequisite knowledge of how static binaries load
6:30 TrashBoatAhoy: so once you know the existence of the level change variable, you need to grep around it to figure out what struct it exists in
6:30 TrashBoatAhoy: once you've done that you can determine the offset of the variable within the struct
6:34 TrashBoatAhoy: level starts on 0
6:34 TrashBoatAhoy: actually the level numbers in the custom start menu are accurate
6:35 TrashBoatAhoy: the thing that's good about marathon is that the symbols aren't stripped from the binary which means you can actually just see them as they're running
6:36 TrashBoatAhoy: yes
6:42 TrashBoatAhoy: the only thing you actually need to do, in theory, is find out where the dynamic_world pointer is in memory. all of the memory addresses for the engine are static so they persist on different launches.
6:42 TrashBoatAhoy: the offset into the struct pointed to by that pointer is the same every time, 590 bytes
6:43 TrashBoatAhoy: so because the symbols aren't stripped, you can basically just search freely for dynamic_world
6:43 TrashBoatAhoy: idk i was just fucking around with that, i'm not terribly familiar with livesplit so i just threw that in there to test
6:43 TrashBoatAhoy: i can confirm that it does, in fact, work when piping game data to livesplit server
6:44 TrashBoatAhoy: i basically just made a python script that polls current_level_number and it pipes it to livesplit server, because that's the only way i can livesplit to work properly on linux
6:45 TrashBoatAhoy: i think you might want to do the same thing with marathon in livesplit potentially - one little hiccup that i came across is that the menu is also counted as level 0
6:46 TrashBoatAhoy: aha so now you're onto my thinking LUL no, ticks stay at 0 in the menu, and they start incrementing as soon as you enter the true level 0
6:47 TrashBoatAhoy: funnily enough that's what i did in my python script to differentiate between the menu and the actual level
6:49 TrashBoatAhoy: you might be interested actually in how i interacted with the livesplit server, so i'll send you my python script
6:49 smoge7: welcome
6:49 smoge7: i gotta immediately dip. gl hf
6:49 TrashBoatAhoy: yeah so you start it in livesplit and it puts itself on port 16834
6:49 TrashBoatAhoy: then you can pipe stuff to it on a socket
6:49 TrashBoatAhoy: it's pretty easy
Replying to @trashboatahoy: yeah so you start it in livesplit and it puts itself on port 168346:49 smoge7: i wanna use this for NDi
6:51 hhosk10: idk if I told you, but my dad will be sueing the company for the accident, they said the hoist can hold 1100 pounds. The transmission was only 551 pounds and the leg bent and the trans fell forwards me
6:51 hhosk10: towards*
6:51 TrashBoatAhoy: uhhh it's a default python socket so i assume it's tcp
6:53 hhosk10: I called him to tell him I’ll be In the hospital until Tuesday and he said “I’m sending the hoist back and shoving it up their ass” he isn’t really happy
6:53 TrashBoatAhoy: fuck hosk you've really been through it recently, i'm glad you're alright
6:54 hhosk10: fuck
6:54 hhosk10: yeah I’m a bit numb on the finger tip
6:54 hhosk10: no feel on the tip at all
6:55 hhosk10: luckily blood is flowing
6:56 TrashBoatAhoy: "i don't touch transmissions...not since the incident" *looks off into the distance*
6:56 TrashBoatAhoy: uhh i'm not assuming that
6:57 TrashBoatAhoy: we need to check to see if ticks reset to 0 when the last level finishes
6:57 TrashBoatAhoy: yeah exactly
6:58 TrashBoatAhoy: oh i gotchu
6:59 TrashBoatAhoy: ok so i dropped it to you in discord - there's a lua command to teleport you to levels - i have it set to 1 in the command i sent you, but you can set it to anything you want
7:01 TrashBoatAhoy: oh just press \ to open the menu
7:01 TrashBoatAhoy: open the terminal sorry
7:02 TrashBoatAhoy: but yeah you can just use lua there, or you can create a script beforehand and have that preloaded - that's what i do because the terminal kinda sucks lol
7:09 TrashBoatAhoy: wb rick