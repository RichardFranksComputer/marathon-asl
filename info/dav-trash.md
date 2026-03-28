OK, so here's the lowdown to make your life easier
Marathon keeps track of the current level by a variable called current_level_number, which is hidden in a struct pointed to by a pointer called "dynamic_world." The struct itself is called dynamic_data and you basically need to find the address of the current_level_number variable for livesplit to keep track of it. 

This is kind of easy with Marathon because it doesn't use ASLR, it's just a static executable, so its base address will always be 0x400000. You need to find the address of the dynamic_world pointer, which you can probably do on a dev cmd line with dumpbin or something. Whatever you do, you can include symbols because the binary for Marathon isn't stripped (or at least it isn't on Linux). The address you get from that can be used to calculate the offset from the executable's entry point that livesplit needs to look at. On Linux it was 0x11dc328 - if you subtract the entry point for a non-PIE exe from that you get: 0x11dc328 - 0x400000 = 0xddc328. This is how I give livesplit the address to look at initially. 

So that dynamic_world pointer points to a struct called "dynamic_data," which itself contains an embedded struct called "game_data." I did the legwork already so I know that the current_level_number variable is 592 bytes into that struct. I'll also give you a C file that you can compile yourself to verify that, it has both structs in there (one is embedded in the other so we need to calculate the size of both). 592 in hex is 0x250, so you provide that as an offset in the .asl livesplit file alongside the entry-point offset. On Linux it comes out like this:
state("alephone")
{
    short current_level : 0xDDC328, 0x250;
}

That's pretty much it tbh, the source code itself is relatively simple, it's just a case of getting it working on Windows (and I don't have a Windows box so I can't test reliably) 