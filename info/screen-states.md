# Screen States

Sourced from `interface.h` line 222 of alephone.

## Memory Address

```
"Classic Marathon Steam.exe"+F10198
```

## Enum Definition

```c
enum { /* states. */
    _display_intro_screens,
    _display_main_menu,
    _display_chapter_heading,
    _display_prologue,
    _display_epilogue,
    _display_credits,
    _display_intro_screens_for_demo,
    _display_quit_screens,
    NUMBER_OF_SCREENS,
    _game_in_progress = NUMBER_OF_SCREENS,
    _quit_game,
    _close_game,
    _switch_demo,
    _revert_game,
    _change_level,
    _begin_display_of_epilogue,
    _displaying_network_game_dialogs,
    NUMBER_OF_GAME_STATES
};
```

## Known State Values

| Value | State           | Notes                                      |
|-------|-----------------|--------------------------------------------|
| 1     | Menu            |                                            |
| 2     | Chapter heading | Use as pause criteria: if value == 2, pause |
| 8     | Gameplay        |                                            |
| 13    | Ending?         | 13 pops up momentarily on game end, unsure if stable | 
