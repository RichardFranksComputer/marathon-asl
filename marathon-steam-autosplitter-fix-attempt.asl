/*

* ==============================================================================
* MARATHON (Classic Marathon Steam) - AUTO SPLITTER
* ==============================================================================
* Version     : v0.3.0 (monotonic progression fix)
* Executable  : Classic Marathon Steam.exe
*
* Memory model:
* module+0xEF6340 → dynamic_world struct
* ```
    +0x000 (int)   = tick count
  ```
* ```
    +0x250 (short) = level number
  ```
* module+0xF10198    (int) = screen state
*
* Timer start  : Map 0, tick transitions 0→1
* Split        : Monotonic level progression (debounced, no double splits)
* Final split  : Screen state enters epilogue (state 4)
* Reset        : Map 0, tick transitions >0 → 0
*
* Key Fix:
* Uses vars.lastSplitLevel to ensure each level is split EXACTLY ONCE,
* regardless of memory oscillation (e.g., 3→4→3→4) or skipped frames.
* ==============================================================================
  */

state("Classic Marathon Steam")
{
int   dynamicWorldPtr : 0x00EF6340;
int   tickCount       : 0x00EF6340, 0x0;
short levelNumber     : 0x00EF6340, 0x250;
int   screenState     : 0x00F10198;
}

startup
{
print("[Marathon] ============================================================");
print("[Marathon] Auto-splitter loaded — v0.3.0 (monotonic progression)");
print("[Marathon] ============================================================");

```
vars.frameCount     = 0;
vars.ptrWasNull     = true;
vars.runComplete    = false;
vars.lastSplitLevel = -1;
```

}

init
{
print("[Marathon] Game process attached — initializing state");

```
vars.frameCount     = 0;
vars.ptrWasNull     = true;
vars.runComplete    = false;
vars.lastSplitLevel = -1;
```

}

update
{
vars.frameCount++;

```
bool ptrValid = (current.dynamicWorldPtr != 0);

// Pointer state change logging
if (ptrValid && vars.ptrWasNull)
{
    print(String.Format("[Marathon] dynamic_world valid (0x{0:X8})",
        current.dynamicWorldPtr));
    vars.ptrWasNull = false;
}
else if (!ptrValid && !vars.ptrWasNull)
{
    print("[Marathon] dynamic_world pointer lost");
    vars.ptrWasNull = true;
}

if (!ptrValid)
    return false;

// Heartbeat
if (vars.frameCount % 300 == 0)
{
    print(String.Format(
        "[Heartbeat] Frame:{0} | Map:{1} | Tick:{2} | Screen:{3} | LastSplit:{4}",
        vars.frameCount,
        current.levelNumber,
        current.tickCount,
        current.screenState,
        vars.lastSplitLevel));
}
```

}

start
{
if (current.levelNumber == 0 &&
old.tickCount == 0 &&
current.tickCount == 1)
{
print("[START] Map 0 | Tick 0→1");

```
    vars.runComplete    = false;
    vars.lastSplitLevel = current.levelNumber; // anchor at 0

    return true;
}

return false;
```

}

reset
{
if (current.levelNumber == 0 &&
old.tickCount > 0 &&
current.tickCount == 0)
{
print(String.Format("[RESET] Tick {0}→0", old.tickCount));

```
    vars.runComplete    = false;
    vars.lastSplitLevel = -1;

    return true;
}

return false;
```

}

split
{
// =========================================================================
// SPLIT 1–26 — Monotonic level progression
// =========================================================================
if (current.levelNumber > vars.lastSplitLevel)
{
// Detect skipped levels (diagnostic only)
if (vars.lastSplitLevel != -1 &&
current.levelNumber > vars.lastSplitLevel + 1)
{
print(String.Format(
"[WARNING] Skipped level(s): {0}→{1}",
vars.lastSplitLevel,
current.levelNumber));
}

```
    print(String.Format(
        "[SPLIT] Map {0}→{1} | Tick:{2}",
        vars.lastSplitLevel,
        current.levelNumber,
        current.tickCount));

    vars.lastSplitLevel = current.levelNumber;
    return true;
}

// =========================================================================
// FINAL SPLIT — Epilogue
// =========================================================================
if (current.screenState == 4 &&
    old.screenState != 4 &&
    !vars.runComplete)
{
    print(String.Format(
        "[FINAL SPLIT] Epilogue | Map:{0} | Tick:{1}",
        current.levelNumber,
        current.tickCount));

    vars.runComplete = true;
    return true;
}

return false;
```

}

isLoading
{
return current.screenState == 2;
}
