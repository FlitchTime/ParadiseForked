/// Used in combo attacks for /datum/martial_art/force. When attacking with an esword, it can be on or off.
#define FORCE_ARTS_SWORD_INACTIVE 0
#define FORCE_ARTS_SWORD_ACTIVE 1

/// Max tiles away the user can start/maintain a Force grab (/datum/martial_art/force).
#define FORCE_GRAB_MAX_DISTANCE 4

/// Max tiles away the user can target Force lightning (/datum/martial_art/force).
#define FORCE_LIGHTNING_MAX_DISTANCE 4

/// Cooldown between attempts to start a Force grab.
#define FORCE_GRAB_COOLDOWN 1 SECONDS

/// Force lightning cooldown.
#define FORCE_LIGHTNING_COOLDOWN 15 SECONDS

/// How long Force lightning stuns the primary target.
#define FORCE_LIGHTNING_STUN_DURATION 3 SECONDS

/// Electrocute power(burn damage) for mobs hit along the lightning line (excluding the primary target).
#define FORCE_LIGHTNING_CHAIN_POWER 15

/// Electrocute power(burn damage) for the primary lightning target.
#define FORCE_LIGHTNING_PRIMARY_POWER 25

/// Force pierce cooldown. 
#define FORCE_PIERCE_COOLDOWN 5 SECONDS

/// Force pierce brute damage to chest.
#define FORCE_PIERCE_DAMAGE 70
