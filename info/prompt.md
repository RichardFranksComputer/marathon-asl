LOGIC

You are building a LiveSplit autosplitter (.asl) for Marathon (Steam version).

You will be given:
1. A reference .asl file (already in correct syntax and structure)
2. A Cheat Engine table defining stable memory addresses

You MUST:
- Reuse patterns, structure, and conventions from the provided .asl
- Only modify logic relevant to Marathon
- Not invent new structural patterns unless absolutely necessary
- Add or update a version comment in the generated `.asl` file
- Append a matching versioned change summary to the end of `README.md`

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

Entry 3:
Name: screen state
Type: 4 Bytes
Address: ["Classic Marathon Steam.exe"+F10198]

Meaning:
- This is a direct 4-byte value stored at module_base + 0xF10198
- Known values:
   - 2 = chapter heading
   - 4 = epilogue
   - 8 = gameplay

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
screenState     → int screenState     : 0x00F10198

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
- When current map > old map

END (FINAL SPLIT):
- Occurs when screen state enters epilogue (screen state 4)
- Must only trigger ONCE

LOADING:
- screen state == 2

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

Final map / ending:
- screen state changes to epilogue
- FINAL SPLIT fires once

----------------------------------------
OUTPUT REQUIREMENT
----------------------------------------

Produce a complete, valid LiveSplit .asl file named:

marathon-steam.asl

It must:
- Compile and run on first try
- Follow structure of the provided reference .asl
- Contain: state, startup/init, update, start, split, reset blocks
- Include necessary vars for state tracking (e.g. runComplete)
- Include minimal logging for unavailable memory
- Include a version number in a header comment in the `.asl`
- Be accompanied by a matching versioned changelog note appended to the end of `README.md`

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
   - Split (map increases)
   - Final split (epilogue screen state, only once)

4. Implement screen-state logic:
   - Use `screenState == 2` for loading / chapter heading
   - Use `screenState == 4` for the final split / epilogue
   - Treat `screenState == 8` as gameplay

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

8. Update version documentation:
   - Add or bump the version number in the `.asl` header comment
   - Append that version number and a short description of the changes to the end of `README.md`

9. Output ONLY the final `.asl` file unless the task explicitly asks for documentation updates too
   - No explanations
   - No comments outside code unless necessary