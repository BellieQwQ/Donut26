extends CanvasLayer

@onready var rect: ColorRect = $Layout/ColorRect

signal closed_iris

func _material():
	return rect.material as ShaderMaterial

func set_radius(value):
	_material().set_shader_parameter("radius", value)

func close(duration = 1.0):
	set_radius(1.2)
	var closingTween = create_tween()
	closingTween.tween_method(set_radius, 1.2, 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	closingTween.finished.connect(func(): emit_signal("closed_iris"))
