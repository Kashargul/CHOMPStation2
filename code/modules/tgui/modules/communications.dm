#define COMM_SCREEN_MAIN		1
#define COMM_SCREEN_STAT		2
#define COMM_SCREEN_MESSAGES	3

#define COMM_AUTHENTICATION_NONE	0
#define COMM_AUTHENTICATION_MIN		1
#define COMM_AUTHENTICATION_MAX		2

#define COMM_MSGLEN_MINIMUM 6
#define COMM_CCMSGLEN_MINIMUM 20

/datum/tgui_module/communications
	name = "Command & Communications"
	tgui_id = "CommunicationsConsole"

	var/emagged = FALSE

	var/current_viewing_message_id = 0
	var/current_viewing_message = null

	var/authenticated = COMM_AUTHENTICATION_NONE
	var/menu_state = COMM_SCREEN_MAIN
	var/ai_menu_state = COMM_SCREEN_MAIN
	var/aicurrmsg

	var/message_cooldown
	var/centcomm_message_cooldown
	var/tmp_alertlevel = 0

	var/stat_msg1
	var/stat_msg2
	var/display_type = "blank"

	var/datum/announcement/priority/crew_announcement

	var/datum/weakref/ATC

	var/list/req_access = list()

/datum/tgui_module/communications/New(host)
	. = ..()
	crew_announcement = new()
	crew_announcement.newscast = TRUE

/datum/tgui_module/communications/tgui_interact(mob/user, datum/tgui/ui)
	if(using_map && !(get_z(user) in using_map.contact_levels))
		to_chat(user, span_danger("Unable to establish a connection: You're too far away from the station!"))
		return FALSE
	. = ..()

/datum/tgui_module/communications/proc/is_authenticated(mob/user, message = TRUE)
	if(authenticated == COMM_AUTHENTICATION_MAX)
		return COMM_AUTHENTICATION_MAX
	else if(isobserver(user))
		var/mob/observer/dead/D = user
		if(D.can_admin_interact())
			return COMM_AUTHENTICATION_MAX
	else if(authenticated)
		return COMM_AUTHENTICATION_MIN
	else
		if(message)
			to_chat(user, span_warning("Access denied."))
		return COMM_AUTHENTICATION_NONE

/datum/tgui_module/communications/proc/change_security_level(mob/user, new_level)
	tmp_alertlevel = new_level
	var/old_level = GLOB.security_level
	if(!tmp_alertlevel) tmp_alertlevel = SEC_LEVEL_GREEN
	if(tmp_alertlevel < SEC_LEVEL_GREEN) tmp_alertlevel = SEC_LEVEL_GREEN
	if(tmp_alertlevel > SEC_LEVEL_BLUE) tmp_alertlevel = SEC_LEVEL_BLUE //Cannot engage delta with this
	set_security_level(tmp_alertlevel)
	if(GLOB.security_level != old_level)
		//Only notify the admins if an actual change happened
		log_game("[key_name(user)] has changed the security level to [get_security_level()].")
		message_admins("[key_name_admin(user)] has changed the security level to [get_security_level()].")
		switch(GLOB.security_level)
			if(SEC_LEVEL_GREEN)
				feedback_inc("alert_comms_green",1)
			if(SEC_LEVEL_YELLOW)
				feedback_inc("alert_comms_yellow",1)
			if(SEC_LEVEL_VIOLET)
				feedback_inc("alert_comms_violet",1)
			if(SEC_LEVEL_ORANGE)
				feedback_inc("alert_comms_orange",1)
			if(SEC_LEVEL_BLUE)
				feedback_inc("alert_comms_blue",1)
	tmp_alertlevel = 0

/datum/tgui_module/communications/tgui_data(mob/user)
	var/list/data = ..()
	data["is_ai"]         = isAI(user) || isrobot(user)
	data["menu_state"]    = data["is_ai"] ? ai_menu_state : menu_state
	data["emagged"]       = emagged
	data["authenticated"] = is_authenticated(user, 0)
	data["authmax"] = data["authenticated"] == COMM_AUTHENTICATION_MAX ? TRUE : FALSE
	data["atcsquelch"] = SSatc.is_squelched()
	data["boss_short"] = using_map.boss_short

	data["stat_display"] =  list(
		"type"   = display_type,
		// "icon"   = display_icon,
		"line_1" = (stat_msg1 ? stat_msg1 : "-----"),
		"line_2" = (stat_msg2 ? stat_msg2 : "-----"),

		"presets" = list(
			list("name" = "blank",    "label" = "Clear",        "desc" = "Blank slate."),
			list("name" = "time",     "label" = "Station Time", "desc" = "The current time according to the station's clock."),
			list("name" = "shuttle",  "label" = "Shuttle ETA",     "desc" = "Display how much time is left."),  //CHOMPEdit we have a shuttle not a tram silly virgo//VOREStation Edit - Shuttle ETA -> Tram ETA because we use trams
			list("name" = "message",  "label" = "Message",      "desc" = "A custom message.")
		),
	)

	data["security_level"] = GLOB.security_level
	switch(GLOB.security_level)
		if(SEC_LEVEL_BLUE)
			data["security_level_color"] = "blue";
		if(SEC_LEVEL_ORANGE)
			data["security_level_color"] = "orange";
		if(SEC_LEVEL_VIOLET)
			data["security_level_color"] = "violet";
		if(SEC_LEVEL_YELLOW)
			data["security_level_color"] = "yellow";
		if(SEC_LEVEL_GREEN)
			data["security_level_color"] = "green";
		if(SEC_LEVEL_RED)
			data["security_level_color"] = "red";
		else
			data["security_level_color"] = "purple";
	data["str_security_level"] = capitalize(get_security_level())
	data["levels"] = list(
		list("id" = SEC_LEVEL_GREEN,  "name" = "Green",  "icon" = "dove"),
		list("id" = SEC_LEVEL_YELLOW, "name" = "Yellow", "icon" = "exclamation-triangle"),
		list("id" = SEC_LEVEL_BLUE,   "name" = "Blue",   "icon" = "eye"),
		list("id" = SEC_LEVEL_ORANGE, "name" = "Orange", "icon" = "wrench"),
		list("id" = SEC_LEVEL_VIOLET, "name" = "Violet", "icon" = "biohazard"),
	)

	var/datum/comm_message_listener/l = obtain_message_listener()
	data["messages"] = l.messages
	data["message_deletion_allowed"] = l != global_message_listener
	data["message_current_id"] = current_viewing_message_id
	data["message_current"] = current_viewing_message

	// data["lastCallLoc"]     = SSshuttle.emergencyLastCallLoc ? format_text(SSshuttle.emergencyLastCallLoc.name) : null
	data["msg_cooldown"] = message_cooldown ? (round((message_cooldown - world.time) / 10)) : 0
	data["cc_cooldown"] = centcomm_message_cooldown ? (round((centcomm_message_cooldown - world.time) / 10)) : 0

	data["esc_callable"] = emergency_shuttle.location() && !emergency_shuttle.online() ? TRUE : FALSE
	data["esc_recallable"] = emergency_shuttle.location() && emergency_shuttle.online() ? TRUE : FALSE
	data["esc_status"] = FALSE
	if(emergency_shuttle.has_eta())
		var/timeleft = emergency_shuttle.estimate_arrival_time()
		data["esc_status"] = emergency_shuttle.online() ? "ETA:" : "RECALLING:"
		data["esc_status"] += " [timeleft / 60 % 60]:[add_zero(num2text(timeleft % 60), 2)]"
	return data

/datum/tgui_module/communications/proc/setCurrentMessage(mob/user, value)
	current_viewing_message_id = value

	var/datum/comm_message_listener/l = obtain_message_listener()
	for(var/list/m in l.messages)
		if(m["id"] == current_viewing_message_id)
			current_viewing_message = m

/datum/tgui_module/communications/proc/setMenuState(mob/user, value)
	if(isAI(user) || isrobot(user))
		ai_menu_state = value
	else
		menu_state = value

/datum/tgui_module/communications/proc/obtain_message_listener()
	if(istype(host, /datum/computer_file/program/comm))
		var/datum/computer_file/program/comm/P = host
		return P.message_core
	return global_message_listener

/proc/post_status(atom/source, command, data1, data2, mob/user = null)
	var/datum/radio_frequency/frequency = radio_controller.return_frequency(1435)

	if(!frequency)
		return

	var/datum/signal/status_signal = new
	status_signal.source = source
	status_signal.transmission_method = TRANSMISSION_RADIO
	status_signal.data["command"] = command

	switch(command)
		if("message")
			status_signal.data["msg1"] = data1
			status_signal.data["msg2"] = data2
			log_admin("STATUS: [user] set status screen message: [data1] [data2]")
			//message_admins("STATUS: [user] set status screen with [PDA]. Message: [data1] [data2]")
		if("alert")
			status_signal.data["picture_state"] = data1

	frequency.post_signal(null, status_signal)

/datum/tgui_module/communications/tgui_act(action, params, datum/tgui/ui)
	if(..())
		return TRUE
	if(using_map && !(get_z(ui.user) in using_map.contact_levels))
		to_chat(ui.user, span_danger("Unable to establish a connection: You're too far away from the station!"))
		return FALSE

	. = TRUE
	if(action == "auth")
		if(!ishuman(ui.user))
			to_chat(ui.user, span_warning("Access denied."))
			return FALSE
		// Logout function.
		if(authenticated != COMM_AUTHENTICATION_NONE)
			authenticated = COMM_AUTHENTICATION_NONE
			crew_announcement.announcer = null
			setMenuState(ui.user, COMM_SCREEN_MAIN)
			return
		// Login function.
		if(check_access(ui.user, access_heads))
			authenticated = COMM_AUTHENTICATION_MIN
		if(check_access(ui.user, access_captain))
			authenticated = COMM_AUTHENTICATION_MAX
			var/obj/item/card/id = ui.user.GetIdCard()
			if(istype(id))
				crew_announcement.announcer = GetNameAndAssignmentFromId(id)
		if(authenticated == COMM_AUTHENTICATION_NONE)
			to_chat(ui.user, span_warning("You need to wear your ID."))

	// All functions below this point require authentication.
	if(!is_authenticated(ui.user))
		return FALSE

	switch(action)
		// main interface
		if("main")
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		if("newalertlevel")
			if(isAI(ui.user) || isrobot(ui.user))
				to_chat(ui.user, span_warning("Firewalls prevent you from changing the alert level."))
				return
			else if(isobserver(ui.user))
				var/mob/observer/dead/D = ui.user
				if(D.can_admin_interact())
					change_security_level(ui.user, text2num(params["level"]))
					return TRUE
			else if(!ishuman(ui.user))
				to_chat(ui.user, span_warning("Security measures prevent you from changing the alert level."))
				return

			if(is_authenticated(ui.user))
				change_security_level(ui.user, text2num(params["level"]))
			else
				to_chat(ui.user, span_warning("You are not authorized to do this."))
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		if("announce")
			if(is_authenticated(ui.user) == COMM_AUTHENTICATION_MAX)
				if(message_cooldown > world.time)
					to_chat(ui.user, span_warning("Please allow at least one minute to pass between announcements."))
					return
				var/input = tgui_input_text(ui.user, "Please write a message to announce to the station crew.", "Priority Announcement", multiline = TRUE, prevent_enter = TRUE)
				if(!input || message_cooldown > world.time || ..() || !(is_authenticated(ui.user) == COMM_AUTHENTICATION_MAX))
					return
				if(length(input) < COMM_MSGLEN_MINIMUM)
					to_chat(ui.user, span_warning("Message '[input]' is too short. [COMM_MSGLEN_MINIMUM] character minimum."))
					return
				crew_announcement.Announce(input)
				message_cooldown = world.time + 600 //One minute

		if("callshuttle")
			if(!is_authenticated(ui.user))
				return

			//CHOMPEdit Start - Add confirmation message
			var/response = tgui_alert(ui.user, "OOC: You are required to Ahelp first before calling the shuttle. Please obtain confirmation from staff before calling the shuttle. \n\n Are you sure you want to call the shuttle?", "Confirm", list("Yes", "No"))

			if(response == "Yes") //CHOMPEdit End
				call_shuttle_proc(ui.user)
				if(emergency_shuttle.online())
					post_status(src, "shuttle", user = ui.user)
				setMenuState(ui.user, COMM_SCREEN_MAIN)

		if("cancelshuttle")
			if(isAI(ui.user) || isrobot(ui.user))
				to_chat(ui.user, span_warning("Firewalls prevent you from recalling the shuttle."))
				return
			var/response = tgui_alert(ui.user, "Are you sure you wish to recall the shuttle?", "Confirm", list("Yes", "No"))
			if(response == "Yes")
				cancel_call_proc(ui.user)
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		if("messagelist")
			current_viewing_message = null
			current_viewing_message_id = null
			if(params["msgid"])
				setCurrentMessage(ui.user, text2num(params["msgid"]))
			setMenuState(ui.user, COMM_SCREEN_MESSAGES)

		if("toggleatc")
			SSatc.reroute_traffic(yes = !SSatc.is_squelched(), silent = TRUE)

		if("delmessage")
			var/datum/comm_message_listener/l = obtain_message_listener()
			if(params["msgid"])
				setCurrentMessage(ui.user, text2num(params["msgid"]))
			var/response = tgui_alert(ui.user, "Are you sure you wish to delete this message?", "Confirm", list("Yes", "No"))
			if(response == "Yes")
				if(current_viewing_message)
					if(l != global_message_listener)
						l.Remove(current_viewing_message)
					current_viewing_message = null
				setMenuState(ui.user, COMM_SCREEN_MESSAGES)

		if("status")
			setMenuState(ui.user, COMM_SCREEN_STAT)

		// Status display stuff
		if("setstat")
			display_type = params["statdisp"]
			switch(display_type)
				if("message")
					post_status(src, "message", stat_msg1, stat_msg2, user = ui.user)
				if("alert")
					post_status(src, "alert", params["alert"], user = ui.user)
				else
					post_status(src, params["statdisp"], user = ui.user)

		if("setmsg1")
			stat_msg1 = reject_bad_text(sanitize(tgui_input_text(ui.user, "Line 1", "Enter Message Text", stat_msg1, 40), 40), 40)
			setMenuState(ui.user, COMM_SCREEN_STAT)

		if("setmsg2")
			stat_msg2 = reject_bad_text(sanitize(tgui_input_text(ui.user, "Line 2", "Enter Message Text", stat_msg2, 40), 40), 40)
			setMenuState(ui.user, COMM_SCREEN_STAT)

		// OMG CENTCOMM LETTERHEAD
		if("MessageCentCom")
			if(is_authenticated(ui.user) == COMM_AUTHENTICATION_MAX)
				if(centcomm_message_cooldown > world.time)
					to_chat(ui.user, span_warning("Arrays recycling. Please stand by."))
					return
				var/input = sanitize(tgui_input_text(ui.user, "Please choose a message to transmit to [using_map.boss_short] via quantum entanglement. \
				Please be aware that this process is very expensive, and abuse will lead to... termination.  \
				Transmission does not guarantee a response. \
				There is a 30 second delay before you may send another message, be clear, full and concise.", "Central Command Quantum Messaging", multiline = TRUE, prevent_enter = TRUE))
				if(!input || ..() || !(is_authenticated(ui.user) == COMM_AUTHENTICATION_MAX))
					return
				if(length(input) < COMM_CCMSGLEN_MINIMUM)
					to_chat(ui.user, span_warning("Message '[input]' is too short. [COMM_CCMSGLEN_MINIMUM] character minimum."))
					return
				CentCom_announce(input, ui.user)
				to_chat(ui.user, span_blue("Message transmitted."))
				log_game("[key_name(ui.user)] has made an IA [using_map.boss_short] announcement: [input]")
				centcomm_message_cooldown = world.time + 300 // 30 seconds
			setMenuState(ui.user, COMM_SCREEN_MAIN)

		// OMG SYNDICATE ...LETTERHEAD
		if("MessageSyndicate")
			if((is_authenticated(ui.user) == COMM_AUTHENTICATION_MAX) && (emagged))
				if(centcomm_message_cooldown > world.time)
					to_chat(ui.user, "Arrays recycling.  Please stand by.")
					return
				var/input = sanitize(tgui_input_text(ui.user, "Please choose a message to transmit to \[ABNORMAL ROUTING CORDINATES\] via quantum entanglement.  Please be aware that this process is very expensive, and abuse will lead to... termination. Transmission does not guarantee a response. There is a 30 second delay before you may send another message, be clear, full and concise.", "To abort, send an empty message.", ""))
				if(!input || ..() || !(is_authenticated(ui.user) == COMM_AUTHENTICATION_MAX))
					return
				if(length(input) < COMM_CCMSGLEN_MINIMUM)
					to_chat(ui.user, span_warning("Message '[input]' is too short. [COMM_CCMSGLEN_MINIMUM] character minimum."))
					return
				Syndicate_announce(input, ui.user)
				to_chat(ui.user, span_blue("Message transmitted."))
				log_game("[key_name(ui.user)] has made an illegal announcement: [input]")
				centcomm_message_cooldown = world.time + 300 // 30 seconds

		if("RestoreBackup")
			to_chat(ui.user, "Backup routing data restored!")
			emagged = FALSE
			setMenuState(ui.user, COMM_SCREEN_MAIN)

/datum/tgui_module/communications/ntos
	ntos = TRUE

/* Etc global procs */
/proc/enable_prison_shuttle(var/mob/user)
	for(var/obj/machinery/computer/prison_shuttle/PS in GLOB.machines)
		PS.allowedtocall = !(PS.allowedtocall)

/proc/call_shuttle_proc(var/mob/user)
	if ((!( ticker ) || !emergency_shuttle.location()))
		return

	if(!GLOB.universe.OnShuttleCall(user))
		to_chat(user, span_notice("Cannot establish a bluespace connection."))
		return

	if(deathsquad.deployed)
		to_chat(user, "[using_map.boss_short] will not allow the shuttle to be called. Consider all contracts terminated.")
		return

	if(emergency_shuttle.deny_shuttle)
		to_chat(user, "The emergency shuttle may not be sent at this time. Please try again later.")
		return

	if(world.time < 6000) // Ten minute grace period to let the game get going without lolmetagaming. -- TLE
		to_chat(user, "The emergency shuttle is refueling. Please wait another [round((6000-world.time)/600)] minute\s before trying again.")
		return

	if(emergency_shuttle.going_to_centcom())
		to_chat(user, "The emergency shuttle may not be called while returning to [using_map.boss_short].")
		return

	if(emergency_shuttle.online())
		to_chat(user, "The emergency shuttle is already on its way.")
		return

	if(ticker.mode.name == "blob")
		to_chat(user, "Under directive 7-10, [station_name()] is quarantined until further notice.")
		return

	emergency_shuttle.call_evac()
	log_game("[key_name(user)] has called the shuttle.")
	message_admins("[key_name_admin(user)] has called the shuttle.", 1)
	admin_chat_message(message = "Emergency evac beginning! Called by [key_name(user)]!", color = "#CC2222") //VOREStation Add

	return

/proc/init_shift_change(var/mob/user, var/force = 0)
	if ((!( ticker ) || !emergency_shuttle.location()))
		return

	if(emergency_shuttle.going_to_centcom())
		to_chat(user, "The shuttle may not be called while returning to [using_map.boss_short].")
		return

	if(emergency_shuttle.online())
		to_chat(user, "The shuttle is already on its way.")
		return

	// if force is 0, some things may stop the shuttle call
	if(!force)
		if(emergency_shuttle.deny_shuttle)
			to_chat(user, "[using_map.boss_short] does not currently have a shuttle available in your sector. Please try again later.")
			return

		if(deathsquad.deployed == 1)
			to_chat(user, "[using_map.boss_short] will not allow the shuttle to be called. Consider all contracts terminated.")
			return

		if(world.time < 54000) // 30 minute grace period to let the game get going
			to_chat(user, "The shuttle is refueling. Please wait another [round((54000-world.time)/60)] minutes before trying again.")
			return

		if(ticker.mode.auto_recall_shuttle)
			//New version pretends to call the shuttle but cause the shuttle to return after a random duration.
			emergency_shuttle.auto_recall = 1

		if(ticker.mode.name == "blob" || ticker.mode.name == "epidemic")
			to_chat(user, "Under directive 7-10, [station_name()] is quarantined until further notice.")
			return

	emergency_shuttle.call_transfer()

	//delay events in case of an autotransfer
	if (isnull(user))
		SSevents.delay_events(EVENT_LEVEL_MODERATE, 9000) //15 minutes
		SSevents.delay_events(EVENT_LEVEL_MAJOR, 9000)

	log_game("[user? key_name(user) : "Autotransfer"] has called the shuttle.")
	message_admins("[user? key_name_admin(user) : "Autotransfer"] has called the shuttle.", 1)
	admin_chat_message(message = "Autotransfer shuttle dispatched, shift ending soon.", color = "#2277BB") //VOREStation Add

	return

/proc/cancel_call_proc(var/mob/user)
	if (!( ticker ) || !emergency_shuttle.can_recall())
		return
	if((ticker.mode.name == "blob")||(ticker.mode.name == "Meteor"))
		return

	if(!emergency_shuttle.going_to_centcom()) //check that shuttle isn't already heading to CentCom
		emergency_shuttle.recall()
		log_game("[key_name(user)] has recalled the shuttle.")
		message_admins("[key_name_admin(user)] has recalled the shuttle.", 1)
	return

/proc/is_relay_online()
	for(var/obj/machinery/telecomms/relay/M in world)
		if(M.stat == 0)
			return 1
	return 0

#undef COMM_SCREEN_MAIN
#undef COMM_SCREEN_STAT
#undef COMM_SCREEN_MESSAGES

#undef COMM_AUTHENTICATION_NONE
#undef COMM_AUTHENTICATION_MIN
#undef COMM_AUTHENTICATION_MAX

#undef COMM_MSGLEN_MINIMUM
#undef COMM_CCMSGLEN_MINIMUM
