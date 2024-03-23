extends Label

var randomStrength:float = 12.0
var shakeFade:float = 3.0
var rng = RandomNumberGenerator.new()
var shakeStrength:float = 0.0

func applyShake():
	shakeStrength = randomStrength
	
func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shakeStrength, shakeStrength), rng.randf_range(-shakeStrength, shakeStrength))
	
func _process(delta):
	if shakeStrength >= 4:
		shakeStrength = lerpf(shakeStrength, 0, shakeFade * delta)
		position += randomOffset()

	self.position = lerp(self.position, Vector2(24, 24), 0.03)
