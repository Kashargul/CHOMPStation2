#define HUMAN_STRIP_DELAY        40   // Takes 40ds = 4s to strip someone.

#define SHOES_SLOWDOWN          0  // How much shoes slow you down by default. Negative values speed you up.

#define CANDLE_LUM 3 // For how bright candles are.

// Item inventory slot bitmasks.
#define SLOT_OCLOTHING  0x1
#define SLOT_ICLOTHING  0x2
#define SLOT_GLOVES     0x4
#define SLOT_EYES       0x8
#define SLOT_EARS       0x10
#define SLOT_MASK       0x20
#define SLOT_HEAD       0x40
#define SLOT_FEET       0x80
#define SLOT_ID         0x100
#define SLOT_BELT       0x200
#define SLOT_BACK       0x400
#define SLOT_POCKET     0x800  // This is to allow items with a w_class of 3 or 4 to fit in pockets.
#define SLOT_DENYPOCKET 0x1000  // This is to deny items with a w_class of 2 or 1 from fitting in pockets.
#define SLOT_TWOEARS    0x2000
#define SLOT_TIE        0x4000
#define SLOT_HOLSTER	0x8000 //24 bit - higher than 0x80000 will overflow

#define ACCESSORY_SLOT_UTILITY  0x1
#define ACCESSORY_SLOT_WEAPON   0x2
#define ACCESSORY_SLOT_ARMBAND  0x4
#define ACCESSORY_SLOT_RANK     0x8
#define ACCESSORY_SLOT_DEPT     0x20
#define ACCESSORY_SLOT_DECOR    0x40
#define ACCESSORY_SLOT_MEDAL    0x80
#define ACCESSORY_SLOT_TIE      0x100
#define ACCESSORY_SLOT_INSIGNIA 0x200
#define ACCESSORY_SLOT_OVER     0x400
//Should these really be 'accessory' accessories
#define ACCESSORY_SLOT_ARMOR_C  0x800
#define ACCESSORY_SLOT_ARMOR_A  0x1000
#define ACCESSORY_SLOT_ARMOR_L  0x2000
#define ACCESSORY_SLOT_ARMOR_S  0x4000
#define ACCESSORY_SLOT_ARMOR_M  0x8000
#define ACCESSORY_SLOT_HELM_C   0x10000 //24 bit - higher than 0x80000 will overflow

#define ACCESSORY_SLOT_RING		0x20000	//rings, knuckledusters
#define ACCESSORY_SLOT_WRIST	0x40000	//wristwatches, wrist PDA maybe?

// Bitmasks for the /obj/item/var/flags_inv variable. These determine when a piece of clothing hides another, i.e. a helmet hiding glasses.
// WARNING: The following flags apply only to the external suit!
#define HIDEGLOVES      0x1
#define HIDESUITSTORAGE 0x2
#define HIDEJUMPSUIT    0x4
#define HIDESHOES       0x8
#define HIDETAIL        0x10
#define HIDETIE         0x20
#define HIDEHOLSTER     0x40 //Some clothing hides holsters, but not all accessories

// WARNING: The following flags apply only to the helmets and masks!
#define HIDEMASK 0x1
#define HIDEEARS 0x2 // Headsets and such.
#define HIDEEYES 0x4 // Glasses.
#define HIDEFACE 0x8 // Dictates whether we appear as "Unknown".

#define BLOCKHEADHAIR   0x20    // Hides the user's hair overlay. Leaves facial hair.
#define BLOCKHAIR       0x40    // Hides the user's hair, facial and otherwise.

// Slots as numbers //
//Hands
#define slot_l_hand      1
#define slot_r_hand      2 //Some things may reference this, try to keep it here
//Shown unless F12 pressed
#define slot_back        3
#define slot_belt        4
#define slot_wear_id     5
#define slot_s_store     6
#define slot_l_store     7
#define slot_r_store     8 //Some things may reference this, try to keep it here
//Shown when inventory unhidden
#define slot_glasses     9
#define slot_wear_mask   10
#define slot_gloves      11
#define slot_head        12
#define slot_shoes       13
#define slot_wear_suit   14
#define slot_w_uniform   15
#define slot_l_ear       16
#define slot_r_ear       17
//Secret slots
#define slot_legs        18
#define slot_tie         19
#define slot_handcuffed  20
#define slot_legcuffed   21
#define slot_in_backpack 22
#define SLOT_TOTAL       22

// Inventory slot strings.
// since numbers cannot be used as associative list keys.
//icon_back, icon_l_hand, etc would be much better names for these...
#define slot_back_str		"slot_back"
#define slot_l_hand_str		"slot_l_hand"
#define slot_r_hand_str		"slot_r_hand"
#define slot_w_uniform_str	"slot_w_uniform"
#define slot_head_str		"slot_head"
#define slot_wear_suit_str	"slot_suit"
#define slot_l_ear_str      "slot_l_ear"
#define slot_r_ear_str      "slot_r_ear"
#define slot_belt_str       "slot_belt"
#define slot_shoes_str      "slot_shoes"
#define slot_wear_mask_str 	"slot_wear_mask"
#define slot_handcuffed_str "slot_handcuffed"
#define slot_legcuffed_str	"slot_legcuffed"
#define slot_wear_id_str  	"slot_wear_id"
#define slot_gloves_str  	"slot_gloves"
#define slot_glasses_str  	"slot_glasses"
#define slot_s_store_str	"slot_s_store"
#define slot_tie_str		"slot_tie"


// Bitflags for clothing parts.
#define HEAD        0x1
#define FACE        0x2
#define EYES        0x4
#define UPPER_TORSO 0x8
#define LOWER_TORSO 0x10
#define CHEST		0x18	// UPPER_TORSO | LOWER_TORSO
#define LEG_LEFT    0x20
#define LEG_RIGHT   0x40
#define LEGS        0x60	// LEG_LEFT | LEG_RIGHT
#define FOOT_LEFT   0x80
#define FOOT_RIGHT  0x100
#define FEET        0x180	// FOOT_LEFT | FOOT_RIGHT
#define ARM_LEFT    0x200
#define ARM_RIGHT   0x400
#define ARMS        0x600	// ARM_LEFT | ARM_RIGHT
#define HAND_LEFT   0x800
#define HAND_RIGHT  0x1000
#define HANDS       0x1800	// HAND_LEFT | HAND_RIGHT
#define FULL_BODY   0xFFFF

// Bitflags for the percentual amount of protection a piece of clothing which covers the body part offers.
// Used with human/proc/get_heat_protection() and human/proc/get_cold_protection().
// The values here should add up to 1, e.g., the head has 30% protection.
#define THERMAL_PROTECTION_HEAD        0.3
#define THERMAL_PROTECTION_UPPER_TORSO 0.15
#define THERMAL_PROTECTION_LOWER_TORSO 0.15
#define THERMAL_PROTECTION_LEG_LEFT    0.075
#define THERMAL_PROTECTION_LEG_RIGHT   0.075
#define THERMAL_PROTECTION_FOOT_LEFT   0.025
#define THERMAL_PROTECTION_FOOT_RIGHT  0.025
#define THERMAL_PROTECTION_ARM_LEFT    0.075
#define THERMAL_PROTECTION_ARM_RIGHT   0.075
#define THERMAL_PROTECTION_HAND_LEFT   0.025
#define THERMAL_PROTECTION_HAND_RIGHT  0.025

// Pressure limits.
#define  HAZARD_HIGH_PRESSURE 550 // This determines at what pressure the ultra-high pressure red icon is displayed. (This one is set as a constant)
#define WARNING_HIGH_PRESSURE 325 // This determines when the orange pressure icon is displayed (it is 0.7 * HAZARD_HIGH_PRESSURE)
#define WARNING_LOW_PRESSURE  50  // This is when the gray low pressure icon is displayed. (it is 2.5 * HAZARD_LOW_PRESSURE)
#define  HAZARD_LOW_PRESSURE  20  // This is when the black ultra-low pressure icon is displayed. (This one is set as a constant)

#define TEMPERATURE_DAMAGE_COEFFICIENT  1.5 // This is used in handle_temperature_damage() for humans, and in reagents that affect body temperature. Temperature damage is multiplied by this amount.
#define BODYTEMP_AUTORECOVERY_DIVISOR   12  // This is the divisor which handles how much of the temperature difference between the current body temperature and 310.15K (optimal temperature) humans auto-regenerate each tick. The higher the number, the slower the recovery. This is applied each tick, so long as the mob is alive.
#define BODYTEMP_AUTORECOVERY_MINIMUM   1   // Minimum amount of kelvin moved toward 310.15K per tick. So long as abs(310.15 - bodytemp) is more than 50.
#define BODYTEMP_COLD_DIVISOR           6   // Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is lower than their body temperature. Make it lower to lose bodytemp faster.
#define BODYTEMP_HEAT_DIVISOR           6   // Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is higher than their body temperature. Make it lower to gain bodytemp faster.
#define BODYTEMP_COOLING_MAX           -30  // The maximum number of degrees that your body can cool down in 1 tick, when in a cold area.
#define BODYTEMP_HEATING_MAX            30  // The maximum number of degrees that your body can heat up in 1 tick,   when in a hot  area.

#define BODYTEMP_HEAT_DAMAGE_LIMIT 360.15 // The limit the human body can take before it starts taking damage from heat.
#define BODYTEMP_COLD_DAMAGE_LIMIT 260.15 // The limit the human body can take before it starts taking damage from coldness.

#define SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE 2.0 // What min_cold_protection_temperature is set to for space-helmet quality headwear. MUST NOT BE 0.
#define   SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE 2.0 // What min_cold_protection_temperature is set to for space-suit quality jumpsuits or suits. MUST NOT BE 0.
#define       HELMET_MIN_COLD_PROTECTION_TEMPERATURE 160 // For normal helmets.
#define        ARMOR_MIN_COLD_PROTECTION_TEMPERATURE 160 // For armor.
#define       GLOVES_MIN_COLD_PROTECTION_TEMPERATURE 2.0 // For some gloves.
#define         SHOE_MIN_COLD_PROTECTION_TEMPERATURE 2.0 // For shoes.

#define  SPACE_SUIT_MAX_HEAT_PROTECTION_TEMPERATURE 5000  // These need better heat protect, but not as good heat protect as firesuits.
#define    FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE 30000 // What max_heat_protection_temperature is set to for firesuit quality headwear. MUST NOT BE 0.
#define FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE 30000 // For fire-helmet quality items. (Red and white hardhats)
#define      HELMET_MAX_HEAT_PROTECTION_TEMPERATURE 600   // For normal helmets.
#define       ARMOR_MAX_HEAT_PROTECTION_TEMPERATURE 600   // For armor.
#define      GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE 1500  // For some gloves.
#define        SHOE_MAX_HEAT_PROTECTION_TEMPERATURE 1500  // For shoes.

// Fire.
#define FIRE_MIN_STACKS          -20
#define FIRE_MAX_STACKS           25
#define FIRE_MAX_FIRESUIT_STACKS  20 // If the number of stacks goes above this firesuits won't protect you anymore. If not, you can walk around while on fire like a badass.

#define THROWFORCE_SPEED_DIVISOR    5  // The throwing speed value at which the throwforce multiplier is exactly 1.
#define THROWNOBJ_KNOCKBACK_SPEED   15 // The minumum speed of a w_class 2 thrown object that will cause living mobs it hits to be knocked back. Heavier objects can cause knockback at lower speeds.
#define THROWNOBJ_KNOCKBACK_DIVISOR 2  // Affects how much speed the mob is knocked back with.

// Suit sensor levels
#define SUIT_SENSOR_OFF      0
#define SUIT_SENSOR_BINARY   1
#define SUIT_SENSOR_VITAL    2
#define SUIT_SENSOR_TRACKING 3

// Hair Defines
#define HAIR_VERY_SHORT 0x1
#define HAIR_TIEABLE 0x4
