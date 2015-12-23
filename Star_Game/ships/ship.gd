
extends "res://shared/rigid_object.gd"

var globals
const type = 'ship'
var owner
var controls
var size_name
var variation
var variation_name
var status
var cargo
var rotate = 0
var force_direction = Vector2(0, 0)
var facing_direction = Vector2(0, 0)
var engage = false
var engineering_extensions = {}
var burners = []
var base_thrust
var previous_pos = Vector2(0, 0)
var current_pos = Vector2(0, 0)
var speed = 0
var brake = false
var core_extensions = {}
var inertial_dampener = 0
var turn_speed = 5
var fire = false
var weapons = {}
var current_weapon
var shields_up = false
var shield_size

var defenses = {}
var tactical_extensions = {}
var supply_extensions = {}




func _ready():
	globals = get_node("/root/globals")


	set_fixed_process(true)

	pass


func _fixed_process(delta):
	previous_pos = current_pos
	current_pos = get_pos()
	speed = Vector2(previous_pos - current_pos).length() / 0.0167
	if speed > 1000:
		speed = 1001
		
#	var turn_amount = (turn_speed / (size + 1)) * delta
#	var s = sign(rotate)
#	var ang = abs(rotate)
#	rotate( min(ang,turn_amount)*s )
#	rotate(rotate * turn_amount)

	var rot = get_rot()
	if rot != rotate:
		var sgn = 1
		var turn_amount = (turn_speed / pow(size + 1, size + 1) * delta)
		if rot + turn_amount < rotate:
			if rotate - rot > deg2rad(179):
				sgn = -1
			else:
				sgn = 1
		elif rot - turn_amount > rotate:
			if rot - rotate> deg2rad(179):
				sgn = 1
			else:
				sgn = -1
		else:
			turn_amount = 0

		
#			turn_amount = rotate - rot
		set_rot(rot +  sgn * turn_amount)

#	var turn_amount = (turn_speed / (size + 1)) * delta
#	var rot = get_rot()
#	if rot != rotate:
#		var sgn = 1
#		if rad2deg(abs(rot - rotate)) > 180 or rad2deg(abs(rotate - rot)) > 180:
#			sgn = -1
#		set_angular_velocity( sgn * turn_amount )
#	else:
#		set_rot(rotate)

		
#		set_rot(rotate)

		
	if engage and energy > .01:
		force_direction.x = cos(get_rot() + deg2rad(90))
		force_direction.y = -sin(get_rot() + deg2rad(90))
		force_direction = force_direction.normalized()

		if speed <= 1000 or force_direction.dot(facing_direction) <= 0:
			apply_impulse(Vector2(0, 0), force_direction * base_thrust * delta)
			energy -= .01
			engines_engage()
			facing_direction = force_direction
		else:
			engines_disengage()
		
		
	else:
		engines_disengage()

	if brake and energy >= 0.2:
		if get_linear_velocity().length() > 0:
			energy -= .2
			inertial_dampener += sqrt(get_mass()) * delta

	else:
		inertial_dampener = 0
		
	if fire and energy >= .25:
		current_weapon.fire(get_rot() + deg2rad(90), get_linear_velocity().length())
		fire = false
	else:
		fire = false

	if shields_up and energy > .01:
		set_shape_transform(shield_index, shield_size.scaled(Vector2(4, 4)))
		get_node("shield").show()
		energy -= .01
	else:
		set_shape_transform(shield_index, shield_size)
		get_node("shield").hide()

	set_linear_damp(inertial_dampener)
	
	
	globals.player_speed = speed
	globals.rotate = rotate
	globals.player_pos = get_pos()
	
	if health <= 0:
		death()


func engines_engage():
	for burner in burners:
		burner.set_emitting(true)
	
func engines_disengage():
	for burner in burners:
		burner.set_emitting(false)


func death():
	
	var explode = globals.explosions.large_normal.instance()
	explode.set_pos(get_pos())
	
	for child in get_children():
		if child.get_name() != 'Camera2D':
			child.free()
	call_deferred('replace_by', explode)
	globals.population -= 1
	get_node("/root/rewards").reward(self)
	get_node("/root/spawner").wait(owner, race)
