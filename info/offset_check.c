#include <stdio.h>
#include <stddef.h>
#include <stdint.h>

#define MAXIMUM_OBJECT_TYPES 64

typedef int16_t int16;
typedef int32_t int32;
typedef uint16_t uint16;

typedef struct {
	int16 x, y;
} world_point2d;

struct game_data {
	int32 game_time_remaining;
	int16 game_type;
	int16 game_options;
	int16 cheat_flags;
	int16 kill_limit;
	int16 initial_random_seed;
	int16 difficulty_level;
	int16 parameters[2];
};

struct dynamic_data {
    int32 tick_count;
    uint16 random_seed;
    struct game_data game_information;
    int16 player_count;
    int16 speaking_player_index;
    int16 unused;
    int16 platform_count;
    int16 endpoint_count;
    int16 line_count;
    int16 side_count;
    int16 polygon_count;
    int16 lightsource_count;
    int16 map_index_count;
    int16 ambient_sound_image_count, random_sound_image_count;
    int16 object_count;
    int16 monster_count;
    int16 projectile_count;
    int16 effect_count;
    int16 light_count;
    int16 default_annotation_count;
    int16 personal_annotation_count;
    int16 initial_objects_count;
    int16 garbage_object_count;
    int16 last_monster_index_to_get_time, last_monster_index_to_build_path;
    int16 new_monster_mangler_cookie, new_monster_vanishing_cookie;
    int16 civilians_killed_by_players;
    int16 random_monsters_left[MAXIMUM_OBJECT_TYPES];
    int16 current_monster_count[MAXIMUM_OBJECT_TYPES];
    int16 random_items_left[MAXIMUM_OBJECT_TYPES];
    int16 current_item_count[MAXIMUM_OBJECT_TYPES];
    int16 current_level_number;
};

int main(int argc, char **argv) {
	printf("offset: %zu\n", offsetof(struct dynamic_data, current_level_number));
	return 0;
}
