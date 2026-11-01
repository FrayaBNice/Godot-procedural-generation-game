@tool
extends Node3D

func remove_wall_up():
	$WallUp.free()
func remove_wall_right():
	$WallRight.free()
func remove_wall_down():
	$WallDown.free()
func remove_wall_left():
	$WallLeft.free()
func remove_door_up():
	$DoorUp.free()
func remove_door_right():
	$DoorRight.free()
func remove_door_down():
	$DoorDown.free()
func remove_door_left():
	$DoorLeft.free()
