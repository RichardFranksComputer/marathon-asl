/*
 * ==============================================================================
 * MARATHON (Classic Marathon Steam) - AUTO SPLITTER
 * ==============================================================================
 * Executable  : Classic Marathon Steam.exe
 * Memory model: static pointer at module+0xEF6340 → dynamic_world struct
 *                 dynamic_world+0x000 (int,   4 bytes) = tick count
 *                 dynamic_world+0x250 (short, 2 bytes) = level number
 *
 * Timer start  : Map 0, tick transitions 0→1 (player begins new game)
 * Split        : Level number increments by 1 (transitions 0→1 through 25→26)
 * Final split  : Map 26, tick count stops incrementing for ≥30 consecutive frames
 * Reset        : Map 0, tick count transitions from any value >0 back to 0
 *
 * KNOWN LIMITATION: Final split uses tick-freeze detection (~0.5s threshold).
 * If the player pauses or the game loses window focus while on Map 26, the
 * freeze detector may fire prematurely. For competitive runs, manual timer
 * stop on Map 26 completion is recommended as a backup.
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
}

startup
{
    print("[Marathon] ============================================================");
    print("[Marathon] Auto-splitter loaded — Classic Marathon Steam");
    print("[Marathon] 27 splits expected: map transitions 0→1…25→26 + Map 26 end");
    print("[Marathon] ============================================================");

    vars.frameCount    = 0;
    vars.frozenFrames  = 0;
    vars.lastKnownTick = 0;
    vars.ptrWasNull    = true;
    vars.runComplete   = false;
}

init
{
    print("[Marathon] Game process attached — initializing state");

    vars.frameCount    = 0;
    vars.frozenFrames  = 0;
    vars.lastKnownTick = 0;
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
        vars.ptrWasNull    = true;
        vars.frozenFrames  = 0;
        vars.lastKnownTick = 0;
    }

    // If the pointer is invalid, halt processing — start/split/reset will not run
    if (!ptrValid)
        return false;

    // -------------------------------------------------------------------------
    // Periodic heartbeat (every ~5 seconds at 60fps)
    // -------------------------------------------------------------------------
    if (vars.frameCount % 300 == 0)
    {
        print(String.Format("[Marathon] Frame:{0} | Map:{1} | Tick:{2} | FrozenFrames:{3} | RunComplete:{4}",
            vars.frameCount,
            current.levelNumber,
            current.tickCount,
            vars.frozenFrames,
            vars.runComplete));
    }

    // -------------------------------------------------------------------------
    // Tick-freeze counter — used by the Map 26 final split detection.
    // Counts consecutive frames where tickCount does not change.
    // Resets to 0 whenever tick advances (normal gameplay).
    // -------------------------------------------------------------------------
    if (current.tickCount > 0 && current.tickCount == vars.lastKnownTick)
    {
        vars.frozenFrames++;
    }
    else
    {
        vars.frozenFrames  = 0;
        vars.lastKnownTick = current.tickCount;
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
        vars.frozenFrames  = 0;
        vars.lastKnownTick = current.tickCount;
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
        vars.frozenFrames  = 0;
        vars.lastKnownTick = 0;
        vars.runComplete   = false;
        return true;
    }

    return false;
}

split
{
    // =========================================================================
    // SPLIT 1–26 — Map transitions
    // Fires each time the level number increments by exactly 1.
    // Covers: 0→1, 1→2, … 25→26  (26 splits)
    // =========================================================================
    if (current.levelNumber == old.levelNumber + 1 &&
        current.levelNumber >= 1 && current.levelNumber <= 26)
    {
        print(String.Format("[Marathon SPLIT] Map {0}→{1} | Tick:{2}",
            old.levelNumber, current.levelNumber, current.tickCount));

        // Reset freeze counter so it starts fresh on the new map
        vars.frozenFrames  = 0;
        vars.lastKnownTick = current.tickCount;
        return true;
    }

    // =========================================================================
    // SPLIT 27 — Map 26 final completion
    // Fires when tick count stops incrementing for 30 consecutive frames while
    // on Map 26 with a non-zero tick (confirms active gameplay, not pre-start).
    // runComplete flag prevents this from re-triggering after the split fires.
    //
    // LIMITATION: Will also trigger if the player pauses or alt-tabs on Map 26.
    // =========================================================================
    if (current.levelNumber == 26 &&
        !vars.runComplete &&
        current.tickCount > 0 &&
        vars.frozenFrames >= 30)
    {
        print(String.Format("[Marathon SPLIT] Map 26 complete | Tick frozen for {0} frames at tick:{1}",
            vars.frozenFrames, current.tickCount));

        vars.runComplete  = true;
        vars.frozenFrames = 0;
        return true;
    }

    return false;
}

isLoading
{
    // No dedicated loading state variable is available from the current memory map.
    // The tick count naturally pauses at menus and on game unfocus, but the timer
    // is only running during an active gameplay session (between start and final split),
    // so real-time and in-game time are approximately equivalent for a clean run.
    return false;
}
