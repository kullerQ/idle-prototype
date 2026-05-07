extends Projectile
class_name Bullet

func _draw() -> void:
	draw_circle(Vector2.ZERO, data.r + 1, Color.BLACK)
	draw_circle(Vector2.ZERO, data.r, Color.GOLDENROD)
