@tool
extends Node3D

func remove_enemy():
	$SimpleEnemy.free()
func remove_pistol_ammo():
	$PistolAmmo.free()
func remove_shot_ammo():
	$ShotgunAmmo.free()
func remove_chain_ammo():
	$ChaingunAmmo.free()
