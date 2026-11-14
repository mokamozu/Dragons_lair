extends Node3D

const TRAIL_OFFSET: float = 1.42
const WIND_VOLUME_MIN_DB: float = -60.0
const WIND_VOLUME_MAX_DB: float = -24.0
const WIND_VOLUME_FADE_SPEED: float = 36.0

var _left_trail: GPUParticles3D
var _right_trail: GPUParticles3D
var _wind_audio: AudioStreamPlayer
var _wind_target_volume_db: float = WIND_VOLUME_MIN_DB


func _ready() -> void:
	_left_trail = _create_wind_trail(-TRAIL_OFFSET)
	_right_trail = _create_wind_trail(TRAIL_OFFSET)
	_wind_audio = AudioStreamPlayer.new()
	_wind_audio.name = "WindAudio"
	_wind_audio.stream = _create_wind_stream()
	_wind_audio.volume_db = WIND_VOLUME_MIN_DB
	add_child(_wind_audio)


func _process(delta: float) -> void:
	_wind_audio.volume_db = move_toward(
		_wind_audio.volume_db,
		_wind_target_volume_db,
		WIND_VOLUME_FADE_SPEED * delta
	)
	if (
		_wind_audio.playing
		and _wind_target_volume_db == WIND_VOLUME_MIN_DB
		and _wind_audio.volume_db <= WIND_VOLUME_MIN_DB
	):
		_wind_audio.stop()


func set_flight_feedback(speed_ratio: float, is_flying: bool, air_braking: bool) -> void:
	var intensity: float = clampf((speed_ratio - 0.45) / 0.55, 0.0, 1.0)
	var emit_trails: bool = is_flying and intensity > 0.05 and not air_braking
	_left_trail.emitting = emit_trails
	_right_trail.emitting = emit_trails
	var should_play_wind: bool = is_flying and intensity > 0.05
	if should_play_wind and not _wind_audio.playing:
		_wind_audio.play()
	_wind_target_volume_db = (
		lerpf(WIND_VOLUME_MIN_DB, WIND_VOLUME_MAX_DB, intensity)
		if should_play_wind
		else WIND_VOLUME_MIN_DB
	)
	_wind_audio.pitch_scale = lerpf(0.85, 1.15, intensity)


func _exit_tree() -> void:
	if _wind_audio != null:
		_wind_audio.stop()
		_wind_audio.stream = null


func _create_wind_trail(side: float) -> GPUParticles3D:
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.name = "WindTrailLeft" if side < 0.0 else "WindTrailRight"
	particles.position = Vector3(side, 1.12, -0.15)
	particles.amount = 36
	particles.lifetime = 0.45
	particles.emitting = false
	particles.explosiveness = 0.0
	particles.randomness = 0.35

	var process_material: ParticleProcessMaterial = ParticleProcessMaterial.new()
	process_material.direction = Vector3(0.0, 0.0, 1.0)
	process_material.spread = 12.0
	process_material.initial_velocity_min = 2.0
	process_material.initial_velocity_max = 5.0
	process_material.gravity = Vector3.ZERO
	process_material.scale_min = 0.035
	process_material.scale_max = 0.09
	process_material.color = Color(0.72, 0.92, 1.0, 0.72)
	particles.process_material = process_material

	var particle_mesh: SphereMesh = SphereMesh.new()
	particle_mesh.radius = 0.06
	particle_mesh.height = 0.12
	particle_mesh.radial_segments = 6
	particle_mesh.rings = 3
	var particle_material: StandardMaterial3D = StandardMaterial3D.new()
	particle_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particle_material.albedo_color = Color(0.72, 0.92, 1.0, 0.72)
	particle_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	particle_mesh.material = particle_material
	particles.draw_pass_1 = particle_mesh
	add_child(particles)
	return particles


func _create_wind_stream() -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 11025
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = 11025
	var samples: PackedByteArray = PackedByteArray()
	samples.resize(stream.mix_rate)
	var generator: RandomNumberGenerator = RandomNumberGenerator.new()
	generator.randomize()
	var filtered_noise: float = 128.0
	for index: int in range(samples.size()):
		filtered_noise = lerpf(filtered_noise, generator.randf_range(0.0, 255.0), 0.12)
		samples[index] = clampi(roundi(filtered_noise), 0, 255)
	stream.data = samples
	return stream
