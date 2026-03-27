Tick info:

- Tick count pauses if game is started, begins rendering, then exits to main menu
- Tick count resets to 0 when player clicks begin game if it had a value.  
- Tick count initializes to 0 when the game is launched
- If tick count is unavailable, the timer should not error, it should handle gracefully but print that tick is unavailable
- Tick count increments every frame

Map number info:
- Maps 0-26 are played in a full run
- On completion of map 26, tick will stop incrementing
- If map number is unavailable, the timer should not error, it should handle gracefullly but print that map is unavailable

Reset condition
- Map 0, tick count 0

Start condition
- Map 0, tick count 1

Split condition
- new map number = old map number + 1

End condition
- Map 26, last tick = new tick
- Does this need improved?  If player pauses or game loses focus on last map, tick count will stop incrementing.
