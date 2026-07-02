/*
 * Assumes levels 0-26 played in order
 * Timer start  : Map 0, tick transitions 0→1 (player begins new game)
 * Split        : Level number increases (transitions 0→1 through 25→26)
 * Final split  : Screen state enters epilogue (state 4)
 * Reset        : Map 0, tick count transitions from any value >0 back to 0
 * 
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
    vars.runComplete    = false;
    vars.lastSplitLevel = -1;
}

init
{
    print("[Marathon] Game process attached — initializing state");

    vars.frameCount     = 0;
    vars.runComplete    = false;
    vars.lastSplitLevel = -1;
}

update
{
    // true if current value at dynamicWorldPtr is not 0
    bool ptrValid = (current.dynamicWorldPtr != 0);

    // if ptrValid false, do not update to prevent crash 
    if (!ptrValid)
        return false;
}

start
{
    if (current.levelNumber == 0 && old.tickCount == 0 && current.tickCount == 1)
    {
        vars.runComplete   = false;
        vars.lastSplitLevel = current.levelNumber;  // last split sets to 0 when game starts
        return true;
    }

    return false;
}

reset
{
    if (current.levelNumber == 0 && old.tickCount > 0 && current.tickCount == 0)
    {
        vars.runComplete    = false;
        vars.lastSplitLevel = -1;
        return true;
    }

    return false;
}

split
{
    if (current.levelNumber > vars.lastSplitLevel)
    {
        vars.lastSplitLevel = current.levelNumber;
        return true;
    }

    if (current.screenState == 13 &&
        old.screenState != 13 &&
        current.levelNumber == 26 && 
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