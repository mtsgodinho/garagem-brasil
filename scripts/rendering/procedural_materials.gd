extends RefCounted
## Microtexturas geradas pelo motor; sem downloads ou texturas pesadas.

static func texture(seed_value: int, normal: bool, strength: float = 0.2) -> NoiseTexture2D:
	var noise := FastNoiseLite.new()
	noise.seed = seed_value
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.18
	noise.fractal_octaves = 3
	var result := NoiseTexture2D.new()
	result.width = 256
	result.height = 256
	result.seamless = true
	result.generate_mipmaps = true
	result.as_normal_map = normal
	result.bump_strength = strength
	result.noise = noise
	return result

static func add_grain(material: StandardMaterial3D, seed_value: int, strength: float, scale: Vector3) -> void:
	material.normal_enabled = true
	material.normal_texture = texture(seed_value,true,strength)
	material.normal_scale = 0.25
	material.uv1_scale = scale
