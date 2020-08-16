extends Area2D

func _ready():
	self.connect("body_entered", self, "_on_FloorHole_body_entered")

func _on_FloorHole_body_entered(body):
	if body.has_method("fall_in_hole"):
		body.fall_in_hole()
