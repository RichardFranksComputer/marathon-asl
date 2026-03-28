## hello please

shout out to TrashBoatAhoy for all the heavy lifting and Dav for game knowledge

They walked so I could run

To modify logic in the ASL, paste the contents of the ASL along with your modifications to `prompt.md` into Claude/ChatGPT and it will spit out a new one.

lsl, asl, lss all must be added to Livesplit.  lsl only exists to set timing method to game time for pause functionality, and is intended to be modified for user preferences.

lss splits when new map number > old map number and stops if screen state = 4 (epilogue screen).

## ASL changelog

- v0.2.0 — Added screen-state tracking at `0x00F10198`, changed loading to chapter-heading state `2`, changed the final split to epilogue state `4`, updated map split logic to `current.levelNumber > old.levelNumber`, and added version metadata to the autosplitter header.


