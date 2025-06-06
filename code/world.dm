//This file is just for the necessary /world definition
//Try looking in /code/game/world.dm, where initialization order is defined

/**
 * # World
 *
 * Two possibilities exist: either we are alone in the Universe or we are not. Both are equally terrifying. ~ Arthur C. Clarke
 *
 * The byond world object stores some basic byond level config, and has a few hub specific procs for managing hub visiblity
 */
/world
	mob = /mob/new_player
	turf = /turf/space
	area = /area/space
	view = "15x15"
	hub = "Exadv1.spacestation13"
	//CHOMPEdit: Accidentally committed this to master instead of pull request. Adding comment to make a pull request. Also to note that I have changed the password so we won't appear on the HUB regardless of TGS3.
	hub_password = "null"
	name = "Space Station 13"
	/*YW EDIT we want to be on the hub
	name = "VOREStation" //VOREStation Edit
	visibility = 0 //VOREStation Edit
	*/
	cache_lifespan = 0
	fps = 40 // If this isnt hard-defined, anything relying on this variable before world load will cry a lot
