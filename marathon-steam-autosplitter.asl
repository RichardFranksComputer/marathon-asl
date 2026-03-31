/*
 * ==============================================================================
 * MARATHON (Classic Marathon Steam) - AUTO SPLITTER
 * ==============================================================================
 * Version     : v0.2.0
 * Executable  : Classic Marathon Steam.exe
 * Memory model: static pointer at module+0xEF6340 → dynamic_world struct
 *                 dynamic_world+0x000 (int,   4 bytes) = tick count
 *                 dynamic_world+0x250 (short, 2 bytes) = level number
 *                 module+0xF10198                 (int, 4 bytes) = screen state
 *
 * Timer start  : Map 0, tick transitions 0→1 (player begins new game)
 * Split        : Level number increases (transitions 0→1 through 25→26)
 * Final split  : Screen state enters epilogue (state 4)
 * Reset        : Map 0, tick count transitions from any value >0 back to 0
 *
 * Full run layout: 27 split points (26 map transitions + 1 final completion)
 * ==============================================================================
 */

state("Classic Marathon Steam")
{
    // Raw pointer to the dynamic_world struct, stored at module+0xEF6340.
    // Checked each frame to confirm data is valid before processing any state.
    int   dynamicWorldPtr : 0x00EF6340;

    // Tick count: first field of dynamic_world (offset 0x000).
    // Increments every rendered frame. Pauses at menus and on game unfocus.
    // Resets to 0 when the player starts a new game.
    int   tickCount       : 0x00EF6340, 0x0;

    // Current level number: dynamic_world offset 0x250.
    // Maps 0–26 represent a full run. Increments as the player progresses.
    short levelNumber     : 0x00EF6340, 0x250;

    // Screen state: direct interface state value at module+0xF10198.
    // 2 = chapter heading, 4 = epilogue, 8 = gameplay.
    int   screenState     : 0x00F10198;
}

startup
{
    print("[Marathon] ============================================================");
    print("[Marathon] Auto-splitter loaded — Classic Marathon Steam (v0.2.0)");
    print("[Marathon] 27 splits expected: map transitions 0→1…25→26 + epilogue end");
    print("[Marathon] ============================================================");

    vars.frameCount    = 0;
    vars.ptrWasNull    = true;
    vars.runComplete   = false;
}

init
{
    print("[Marathon] Game process attached — initializing state");

    vars.frameCount    = 0;
    vars.ptrWasNull    = true;
    vars.runComplete   = false;
}

update
{
    vars.frameCount++;

    bool ptrValid = (current.dynamicWorldPtr != 0);

    // -------------------------------------------------------------------------
    // Pointer availability logging — only print on state change to avoid spam
    // -------------------------------------------------------------------------
    if (ptrValid && vars.ptrWasNull)
    {
        print(String.Format("[Marathon] dynamic_world pointer valid (0x{0:X8}) — tick and map available",
            current.dynamicWorldPtr));
        vars.ptrWasNull = false;
    }
    else if (!ptrValid && !vars.ptrWasNull)
    {
        print("[Marathon] dynamic_world pointer is null — tick and map unavailable");
        vars.ptrWasNull  = true;
    }

    // If the pointer is invalid, halt processing — start/split/reset will not run
    if (!ptrValid)
        return false;

    // -------------------------------------------------------------------------
    // Periodic heartbeat (every ~5 seconds at 60fps)
    // -------------------------------------------------------------------------
    if (vars.frameCount % 300 == 0)
    {
        print(String.Format("[Marathon] Frame:{0} | Map:{1} | Tick:{2} | ScreenState:{3} | RunComplete:{4}",
            vars.frameCount,
            current.levelNumber,
            current.tickCount,
            current.screenState,
            vars.runComplete));
    }
}

start
{
    // Condition: Map 0, tick transitions from exactly 0 to exactly 1.
    // This fires on the very first frame of gameplay after "Begin Game" is clicked.
    // Pointer validity is already guaranteed by update returning false when null.
    if (current.levelNumber == 0 && old.tickCount == 0 && current.tickCount == 1)
    {
        print("[Marathon START] Map 0 | Tick 0→1 | Timer started");
        vars.runComplete   = false;
        return true;
    }

    return false;
}

reset
{
    // Condition: On Map 0, tick count drops back to 0 from a non-zero value.
    // This corresponds to the player clicking "Begin Game" during or after a run.
    // A tick of 0 on game launch is not a transition (no old value >0), so this
    // does not fire spuriously on initial load.
    if (current.levelNumber == 0 && old.tickCount > 0 && current.tickCount == 0)
    {
        print(String.Format("[Marathon RESET] Map 0 | Tick {0}→0 | Timer reset", old.tickCount));
        vars.runComplete   = false;
        return true;
    }

    return false;
}

split
{
    // =========================================================================
    // SPLIT 1–26 — Map transitions
    // Fires each time the level number increases.
    // Covers normal progression 0→1, 1→2, … 25→26.
    // =========================================================================
    if (current.levelNumber != old.levelNumber)
    {
        print(String.Format("[Marathon SPLIT] Map {0}→{1} | Tick:{2}",
            old.levelNumber, current.levelNumber, current.tickCount));
        return true;
    }

    // =========================================================================
    // SPLIT 27 — Final completion
    // Fires when the interface enters epilogue (screen state 4).
    // runComplete prevents this from re-triggering after the split fires.
    // =========================================================================
    if (current.screenState == 4 &&
        old.screenState != 4 &&
        !vars.runComplete)
    {
        print(String.Format("[Marathon SPLIT] Epilogue reached | Map:{0} | Tick:{1}",
            current.levelNumber, current.tickCount));

        vars.runComplete = true;
        return true;
    }

    return false;
}

isLoading
{
    // Chapter heading screens use state 2 and should pause game time.
    return current.screenState == 2;
}
