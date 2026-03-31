/*
 * ==============================================================================
 * MARATHON (Classic Marathon Steam) - AUTO SPLITTER
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
    vars.frameCount     = 0;
    vars.ptrWasNull     = true;
    vars.runComplete    = false;
    vars.lastSplitLevel = -1;
}

init
{
    vars.frameCount     = 0;
    vars.ptrWasNull     = true;
    vars.runComplete    = false;
    vars.lastSplitLevel = -1;
}

update
{
    vars.frameCount++;
    bool ptrValid = (current.dynamicWorldPtr != 0);
    if (!ptrValid)
        return false;
}

start
{
    if (current.levelNumber == 0 &&
        old.tickCount == 0 &&
        current.tickCount == 1)
    {
        vars.runComplete    = false;
        vars.lastSplitLevel = current.levelNumber;
        return true;
    }
    return false;
}

reset
{
    if (current.levelNumber == 0 &&
        old.tickCount > 0 &&
        current.tickCount == 0)
    {
        vars.runComplete    = false;
        vars.lastSplitLevel = -1;
        return true;
    }
    return false;
}

split
{
    // SPLIT 1–26 — monotonic level progression
    if (current.levelNumber > vars.lastSplitLevel)
    {
        vars.lastSplitLevel = current.levelNumber;
        return true;
    }

    // SPLIT 27 — final completion
    if (current.screenState == 4 &&
        old.screenState != 4 &&
        !vars.runComplete)
    {
        vars.runComplete = true;
        return true;
    }

    return false;
}

isLoading
{
    return current.screenState == 2;
}
