extends Node2D
class_name Spikes

@onready var hitbox = $Hitbox


func _ready():
	hitbox.area_entered.connect(on_deal_damage)
	
func on_deal_damage(area):
	if area is Hurtbox and area.get_parent().is_in_group("Player"):
		area.deal_damage.emit(1, global_position)
