/datum/wires/mines
	wire_count = 7
	randomize = TRUE
	holder_type = /obj/effect/mine
	proper_name = "Explosive Wires"

/datum/wires/mines/New(atom/_holder)
	wires = list(WIRE_EXPLODE, WIRE_EXPLODE_DELAY, WIRE_DISARM, WIRE_BADDISARM)
	return ..()
#define WIRE_TRAP		64

/datum/wires/mines/get_status()
	. = ..()
	. += "\[Warning: detonation may occur even with proper equipment.]"

/datum/wires/mines/proc/explode()
	return

/datum/wires/mines/on_cut(wire, mend)
	var/obj/effect/mine/C = holder

	switch(wire)
		if(WIRE_EXPLODE)
			C.visible_message("[icon2html(C,viewers(holder))] *BEEE-*", "[icon2html(C,viewers(holder))] *BEEE-*")
			C.explode()

		if(WIRE_EXPLODE_DELAY)
			C.visible_message("[icon2html(C,viewers(holder))] *BEEE-*", "[icon2html(C,viewers(holder))] *BEEE-*")
			C.explode()

		if(WIRE_DISARM)
			C.visible_message("[icon2html(C,viewers(holder))] *click!*", "[icon2html(C,viewers(holder))] *click!*")
			var/obj/effect/mine/MI = new C.mineitemtype(get_turf(C))

			if(C.trap)
				MI.trap = C.trap
				C.trap = null
				MI.trap.forceMove(MI)

			spawn(0)
				qdel(C)

		if(WIRE_BADDISARM)
			C.visible_message("[icon2html(C,viewers(holder))] *BEEPBEEPBEEP*", "[icon2html(C,viewers(holder))] *BEEPBEEPBEEP*")
			spawn(20)
				C.explode()

		if(WIRE_TRAP)
			C.visible_message("[icon2html(C,viewers(holder))] *click!*", "[icon2html(C,viewers(holder))] *click!*")

			if(mend)
				C.visible_message("[icon2html(C,viewers(holder))] - The mine recalibrates[C.camo_net ? ", revealing \the [C.trap] inside." : "."]")

				C.alpha = 255

	..()

/datum/wires/mines/on_pulse(wire)
	var/obj/effect/mine/C = holder
	if(is_cut(wire))
		return
	switch(wire)
		if(WIRE_EXPLODE)
			C.visible_message("[icon2html(C,viewers(holder))] *beep*", "[icon2html(C,viewers(holder))] *beep*")

		if(WIRE_EXPLODE_DELAY)
			C.visible_message("[icon2html(C,viewers(holder))] *BEEPBEEPBEEP*", "[icon2html(C,viewers(holder))] *BEEPBEEPBEEP*")
			spawn(20)
				C.explode()

		if(WIRE_DISARM)
			C.visible_message("[icon2html(C,viewers(holder))] *ping*", "[icon2html(C,viewers(holder))] *ping*")

		if(WIRE_BADDISARM)
			C.visible_message("[icon2html(C,viewers(holder))] *ping*", "[icon2html(C,viewers(holder))] *ping*")

		if(WIRE_TRAP)
			C.visible_message("[icon2html(C,viewers(holder))] *ping*", "[icon2html(C,viewers(holder))] *ping*")

	..()

#undef WIRE_TRAP

/datum/wires/mines/interactable(mob/user)
	var/obj/effect/mine/M = holder
	return M.panel_open
