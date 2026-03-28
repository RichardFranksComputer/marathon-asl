LOGIC

You are building a LiveSplit autosplitter (.asl) for Marathon (Steam version).

You will be given:
1. A reference .asl file (already in correct syntax and structure)
2. A Cheat Engine table defining stable memory addresses

You MUST:
- Reuse patterns, structure, and conventions from the provided .asl
- Only modify logic relevant to Marathon
- Not invent new structural patterns unless absolutely necessary

----------------------------------------
CHEAT ENGINE MEMORY DEFINITIONS
----------------------------------------

Entry 1:
Name: dynamic_world pointer (also holds tick at offset 0)
Type: 4 Bytes
Address: ["Classic Marathon Steam.exe"+EF6340]

Meaning:
- This is a pointer stored at module_base + 0xEF6340
- It points to the dynamic_world struct

Entry 2:
Name: level number
Type: 2 Bytes
Address: ["Classic Marathon Steam.exe"+EF6340] + 0x250

Meaning:
- Dereference the pointer at (module_base + 0xEF6340)
- Then read a 2-byte value at offset 0x250

----------------------------------------
ASL TRANSLATION RULES
----------------------------------------

Module name:
"Classic Marathon Steam.exe" → state("Classic Marathon Steam")

Pointer:
["module"+offset] → base pointer → int ptr : 0xOFFSET

Dereferenced values:
["module"+offset] + X → int/short value : 0xOFFSET, X

Therefore:

dynamicWorldPtr → int dynamicWorldPtr : 0x00EF6340
tickCount       → int tickCount       : 0x00EF6340, 0x0
levelNumber     → short levelNumber   : 0x00EF6340, 0x250

----------------------------------------
GAME LOGIC
----------------------------------------

Tick behavior:
- Starts at 0 when game launches
- Resets to 0 when player clicks "Begin Game" (if previously non-zero)
- Increments every frame
- Stops incrementing when game stops updating (menu, pause, or final level completion)

Map behavior:
- Maps range from 0 to 26 inclusive
- A full run progresses sequentially from 0 → 26
- On finishing map 26, tick stops incrementing

----------------------------------------
TIMER CONDITIONS
----------------------------------------

RESET:
- Map == 0 AND tick == 0
- Must ONLY trigger when transitioning from tick > 0 → tick == 0

START:
- Map == 0 AND tick == 1

SPLIT:
- When current map == old map + 1

END (FINAL SPLIT):
- Occurs on map 26 when tick stops incrementing
- Must avoid false triggers from pauses or focus loss
- Must only trigger ONCE

----------------------------------------
FAILURE HANDLING
----------------------------------------

If dynamicWorldPtr == 0:
- Do NOT crash
- Do NOT evaluate logic
- Print/log once: "dynamic_world unavailable"

If tick or map cannot be read:
- Do NOT crash
- Gracefully skip logic
- Print/log once:
  - "tick unavailable"
  - "map unavailable"

----------------------------------------
STATE SAFETY REQUIREMENTS
----------------------------------------

- Use old vs current comparisons for all transitions
- Ensure no condition can double-trigger
- Ensure splits cannot fire multiple times
- Ensure end condition cannot loop

----------------------------------------
EXPECTED BEHAVIOR TRACE
----------------------------------------

Cold launch:
- tick = 0 → nothing happens

Player clicks Begin Game:
- tick: 0 → 1 → START fires

Gameplay:
- tick increments continuously
- map increments → SPLIT fires each time

Final map (26):
- tick stops incrementing
- after stable freeze → FINAL SPLIT fires once

----------------------------------------
OUTPUT REQUIREMENT
----------------------------------------

Produce a complete, valid LiveSplit .asl file named:

marathon-steam.asl

It must:
- Compile and run on first try
- Follow structure of the provided reference .asl
- Contain: state, startup/init, update, start, split, reset blocks
- Include necessary vars for state tracking (e.g. runComplete, freeze detection)
- Include minimal logging for unavailable memory

INSTRUCTIONS

1. Analyze the provided reference .asl:
   - Identify naming conventions
   - Identify structure (state, init, update, etc.)
   - Identify how memory is declared and accessed
   - Mirror its style exactly

2. Translate Cheat Engine addresses into ASL correctly:
   - Respect pointer dereferencing rules
   - Do NOT treat pointer as static value
   - Do NOT guess offsets

3. Implement all timer logic EXACTLY as defined:
   - Reset (strict transition only)
   - Start (single-frame trigger)
   - Split (map increments)
   - Final split (tick freeze on map 26, only once)

4. Implement freeze detection safely:
   - Detect when tick stops changing across frames
   - Use a frame counter threshold (~30 frames)
   - Reset counter whenever tick changes

5. Add state guards:
   - Prevent duplicate splits
   - Prevent multiple end triggers
   - Ensure stability if memory disappears mid-run

6. Handle missing memory gracefully:
   - Use update() to short-circuit logic when pointer is null
   - Do not spam logs every frame

7. Validate your logic BEFORE output:
   - Walk through full run lifecycle
   - Ensure no race conditions
   - Ensure no false resets or splits

8. Output ONLY the final .asl file
   - No explanations
   - No comments outside code unless necessary