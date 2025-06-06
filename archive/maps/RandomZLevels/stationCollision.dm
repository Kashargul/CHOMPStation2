/* Station-Collision(sc) away mission map specific stuff
 *
 * Notes:
 *		Feel free to use parts of this map, or even all of it for your own project. Just include me in the credits :)
 *
 *		Some of this code unnecessary, but the intent is to add a little bit of everything to serve as examples
 *		for anyone who wants to make their own stuff.
 *
 * Contains:
 *		Areas
 *		Landmarks
 *		Guns
 *		Safe code hints
 *		Captain's safe
 *		Modified Nar-Sie
 */

/*
 * Areas
*/
//Gateroom gets its own APC specifically for the gate
/area/awaymission/gateroom

//Library, medbay, storage room
/area/awaymission/southblock

//Arrivals, security, hydroponics, shuttles (since they dont move, they dont need specific areas)
/area/awaymission/arrivalblock

//Crew quarters, cafeteria, chapel
/area/awaymission/midblock

//engineering, bridge (not really north but it doesnt really need its own APC)
/area/awaymission/northblock

//That massive research room
/area/awaymission/research

//Syndicate shuttle
/area/awaymission/syndishuttle


/*
 * Landmarks - Instead of spawning a new object type, I'll spawn the bible using a landmark!
 */
/obj/effect/landmark/sc_bible_spawner
	name = "Safecode hint spawner"
	delete_me = TRUE

/obj/effect/landmark/sc_bible_spawner/Initialize(mapload)
	. = ..()
	var/obj/item/storage/bible/B = new /obj/item/storage/bible/booze(src.loc)
	B.name = "The Holy book of the Geometer"
	B.deity_name = "Narsie"
	B.icon_state = "melted"
	B.item_state = "melted"
	new /obj/item/paper/sc_safehint_paper_bible(B)
	new /obj/item/pen(B)

/*
 * Guns - I'm making these specifically so that I dont spawn a pile of fully loaded weapons on the map.
 */
//Captain's retro laser - Fires practice laser shots instead.
obj/item/gun/energy/laser/retro/sc_retro
	name ="retro laser"
	icon_state = "retro"
	desc = "An older model of the basic lasergun, no longer used by NanoTrasen's security or military forces."
	projectile_type = "/obj/item/projectile/practice"
	clumsy_check = 0 //No sense in having a harmless gun blow up in the clowns face

//Syndicate silenced pistol. This definition is not necessary, it's just habit.
/obj/item/gun/projectile/silenced/sc_silenced

//Make it so that these guns only spawn with a couple bullets... if any
/obj/item/gun/projectile/silenced/sc_silenced/Initialize(mapload)
	. = ..()
	for(var/ammo in loaded)
		if(prob(95)) //95% chance
			loaded -= ammo

//Syndicate sub-machine guns.
/obj/item/gun/projectile/automatic/c20r/sc_c20r

/obj/item/gun/projectile/automatic/c20r/sc_c20r/Initialize(mapload)
	. = ..()
	for(var/ammo in loaded)
		if(prob(95)) //95% chance
			loaded -= ammo

//Barman's shotgun
/obj/item/gun/projectile/shotgun/pump/sc_pump

/obj/item/gun/projectile/shotgun/pump/sc_pump/Initialize(mapload)
	. = ..()
	for(var/ammo in loaded)
		if(prob(95)) //95% chance
			loaded -= ammo

//Lasers
/obj/item/gun/energy/laser/practice/sc_laser
	name = "Old laser"
	desc = "A once potent weapon, years of dust have collected in the chamber and lens of this weapon, weakening the beam significantly."
	clumsy_check = 0

/*
 * Safe code hints
 */

//These vars hold the code itself, they'll be generated at round-start
var/sc_safecode1 = "[rand(0,9)]"
var/sc_safecode2 = "[rand(0,9)]"
var/sc_safecode3 = "[rand(0,9)]"
var/sc_safecode4 = "[rand(0,9)]"
var/sc_safecode5 = "[rand(0,9)]"

//Pieces of paper actually containing the hints
/obj/item/paper/sc_safehint_paper_prison
	name = "smudged paper"

/obj/item/paper/sc_safehint_paper_prison/Initialize(mapload, text, title)
	. = ..()
	info = span_italics("The ink is smudged, you can only make out a couple numbers:") + " '[sc_safecode1]**[sc_safecode4]*'"

/obj/item/paper/sc_safehint_paper_hydro
	name = "shredded paper"
/obj/item/paper/sc_safehint_paper_hydro/Initialize(mapload, text, title)
	. = ..()
	info = span_italics("Although the paper is shredded, you can clearly see the number:") + " '[sc_safecode2]'"

/obj/item/paper/sc_safehint_paper_caf
	name = "blood-soaked paper"
	//This does not have to be in New() because it is a constant. There are no variables in it i.e. [sc_safcode]
	info = span_red(span_italics("This paper is soaked in blood, it is impossible to read any text."))

/obj/item/paper/sc_safehint_paper_bible
	name = "hidden paper"

/obj/item/paper/sc_safehint_paper_bible/Initialize(mapload, text, title)
	. = ..()
	info = span_italics("It would appear that the pen hidden with the paper had leaked ink over the paper. \
			However you can make out the last three digits:") + "' [sc_safecode3][sc_safecode4][sc_safecode5]'"

/obj/item/paper/sc_safehint_paper_shuttle
	info = span_bold("Target:") + " Research-station Epsilon<br> " + span_bold("Objective:")\ +
			{" Prototype weaponry. The captain likely keeps them locked in her safe.<br>
			<br>
			Our on-board spy has learned the code and has hidden away a few copies of the code around the station. Unfortunatly he has been captured by security
			Your objective is to split up, locate any of the papers containing the captain's safe code, open the safe and
			secure anything found inside. If possible, recover the imprisioned syndicate operative and recieve the code from him.<br>
			<br>
			<u>As always, eliminate anyone who gets in the way.</u><br>
			<br>
			Your assigned ship is designed specifically for penetrating the hull of another station or ship with minimal damage to operatives.
			It is completely fly-by-wire meaning you have just have to enjoy the ride and when the red light comes on... find something to hold onto!
			"}
/*
 * Captain's safe
 */
/obj/item/storage/secure/safe/sc_ssafe
	name = "Captain's secure safe"

/obj/item/storage/secure/safe/sc_ssafe/Initialize(mapload)
	. = ..()
	l_code = "[sc_safecode1][sc_safecode2][sc_safecode3][sc_safecode4][sc_safecode5]"
	l_set = 1
	new /obj/item/gun/energy/mindflayer(src)
	new /obj/item/soulstone(src)
	new /obj/item/clothing/head/helmet/space/cult(src)
	new /obj/item/clothing/suit/space/cult(src)
	//new /obj/item/teleportation_scroll(src)
	new /obj/item/ore/diamond(src)

/*
 * Modified Nar-Sie
 */
/obj/machinery/singularity/narsie/sc_Narsie
	desc = "Your body becomes weak and your feel your mind slipping away as you try to comprehend what you know can't be possible."
	move_self = 0 //Contianed narsie does not move!
	grav_pull = 0 //Contained narsie does not pull stuff in!

//Override this to prevent no adminlog runtimes and admin warnings about a singularity without containment
/obj/machinery/singularity/narsie/sc_Narsie/admin_investigate_setup()
	return

/obj/machinery/singularity/narsie/sc_Narsie/process()
	eat()
	if(prob(25))
		mezzer()

/obj/machinery/singularity/narsie/sc_Narsie/consume(var/atom/A)
	if(is_type_in_list(A, uneatable))
		return 0
	if (isliving(A))
		var/mob/living/L = A
		L.gib()
	else if(istype(A,/obj/))
		var/obj/O = A
		O.ex_act(1.0)
		if(O) qdel(O)
	else if(isturf(A))
		var/turf/T = A
		if(T.intact)
			for(var/obj/O in T.contents)
				if(O.level != 1)
					continue
				if(O.invisibility == INVISIBILITY_ABSTRACT)
					src.consume(O)
		T.ChangeTurf(/turf/space)
	return

/obj/machinery/singularity/narsie/sc_Narsie/ex_act()
	return
