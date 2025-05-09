// Rune colors, for easy reference
#define RUNE_COLOR_TALISMAN "#0000FF"
#define RUNE_COLOR_TELEPORT "#551A8B"
#define RUNE_COLOR_OFFER "#FFFFFF"
#define RUNE_COLOR_DARKRED "#7D1717"
#define RUNE_COLOR_MEDIUMRED "#C80000"
#define RUNE_COLOR_BURNTORANGE "#CC5500"
#define RUNE_COLOR_RED "#FF0000"
#define RUNE_COLOR_LIGHTRED "#FF726F"
#define RUNE_COLOR_EMP "#4D94FF"
#define RUNE_COLOR_SUMMON "#00FF00"

#define is_sacrifice_target(A) SSticker.mode?.cult_objs.is_sac_target(A)

// Blood magic
/// Maximum number of spells with an empowering rune
#define MAX_BLOODCHARGE 4
/// Maximum number of spells without an empowering rune
#define RUNELESS_MAX_BLOODCHARGE 1
#define BLOOD_SPEAR_COST 150
#define BLOOD_BARRAGE_COST 300
#define BLOOD_ORB_COST 50
#define BLOOD_RECHARGE_COST 75
#define BLOOD_BEAM_COST 500
#define METAL_TO_CONSTRUCT_SHELL_CONVERSION 50
#define GHOST_SUMMONS_PER_READY 10
#define GHOST_SUMMONS_CONVERT 1
#define GHOST_SUMMONS_OBJECTIVE 3

// Cult Status
/// At what population does it switch to highpop values
#define CULT_POPULATION_THRESHOLD 100
/// Percent before rise (Lowpop)
#define CULT_RISEN_LOW 0.2
/// Percent before ascend (Lowpop)
#define CULT_ASCENDANT_LOW 0.3
/// Percent before rise (Highpop)
#define CULT_RISEN_HIGH 0.1
/// Percent before ascend (Highpop)
#define CULT_ASCENDANT_HIGH 0.2

// Screen locations
#define DEFAULT_BLOODSPELLS "6:-29,4:-2"
#define DEFAULT_BLOODTIP "14:6,14:27"
#define DEFAULT_TOOLTIP "6:-29,5:-2"

// Text
#define CULT_GREETING "<span class='cultlarge'>You catch a glimpse of the Realm of [SSticker.cultdat.entity_name], [SSticker.cultdat.entity_title3]. \
						You now see how flimsy the world is, you see that it should be open to the knowledge of [SSticker.cultdat.entity_name].</span>"

#define CULT_CURSES list("Заправщик шаттла только что перерезал себе горло и умолял о смерти.",\
			"Навигационная программа шаттла была заменена файлом, содержащим два слова: «ОНО ИДЁТ».",\
			"Уборщик шаттла вырвал свои кишки и начал рисовать странные фигуры на полу.",\
			"Инженер шаттла кричала «СМЕРТЬ НЕ КОНЕЦ» и вырывала проводку, пока электрический разряд не испепелил её плоть.",\
			"Инспектор шаттла начала безумно смеяться в рацию и бросилась в турбину двигателя.",\
			"Диспетчер шаттла был найден мертвым, на его теле были вырезаны кровавые символы.",\
			"Стив так долго держался за лампочку, что у него отнялись руки.")

// Misc
#define SOULS_TO_REVIVE 3
#define BLOODCULT_EYE "#FF0000"
#define SUMMON_POSSIBILITIES 3
#define CULT_CLOTHING list(/obj/item/clothing/suit/hooded/cultrobes, /obj/item/clothing/suit/space/cult, /obj/item/clothing/suit/hooded/cultrobes/cult_shield, \
						   /obj/item/clothing/suit/hooded/cultrobes/flagellant_robe, /obj/item/clothing/glasses/hud/health/night/cultblind)

// Cult objective status
#define NARSIE_IS_ASLEEP 0
#define NARSIE_DEMANDS_SACRIFICE 1
#define NARSIE_NEEDS_SUMMONING 2
#define NARSIE_HAS_RISEN 3
#define NARSIE_HAS_FALLEN -1

#define CULT_PLAYER_PER_CULTIST 20
