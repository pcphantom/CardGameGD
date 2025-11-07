extends Node

# SoundManager Autoload Singleton
#
# Manages all sound effects and music, replacing Sounds.java.
# Uses audio player pooling for overlapping sound effects.
#
# Accessible globally via: SoundManager.play_sound(SoundTypes.Sound.SUMMONED)

# Sound configuration
const SOUND_CONFIG: Dictionary = {
	SoundTypes.Sound.BACKGROUND1: {"path": "res://assets/sounds/combat1.ogg", "volume": 0.1, "looping": true},
	SoundTypes.Sound.BACKGROUND2: {"path": "res://assets/sounds/combat2.ogg", "volume": 0.1, "looping": true},
	SoundTypes.Sound.BACKGROUND3: {"path": "res://assets/sounds/combat3.ogg", "volume": 0.1, "looping": true},
	SoundTypes.Sound.POSITIVE_EFFECT: {"path": "res://assets/sounds/positive_effect.ogg", "volume": 0.3, "looping": false},
	SoundTypes.Sound.NEGATIVE_EFFECT: {"path": "res://assets/sounds/negative_effect.ogg", "volume": 0.3, "looping": false},
	SoundTypes.Sound.MAGIC: {"path": "res://assets/sounds/magic.ogg", "volume": 0.3, "looping": false},
	SoundTypes.Sound.ATTACK: {"path": "res://assets/sounds/attack.ogg", "volume": 0.3, "looping": false},
	SoundTypes.Sound.SUMMON_DROP: {"path": "res://assets/sounds/summon_drop.ogg", "volume": 0.3, "looping": false},
	SoundTypes.Sound.SUMMONED: {"path": "res://assets/sounds/summoned.ogg", "volume": 0.3, "looping": false},
	SoundTypes.Sound.DAMAGED: {"path": "res://assets/sounds/damaged.ogg", "volume": 0.3, "looping": false},
	SoundTypes.Sound.DEATH: {"path": "res://assets/sounds/death.ogg", "volume": 0.5, "looping": false},
	SoundTypes.Sound.GAMEOVER: {"path": "res://assets/sounds/gameover.ogg", "volume": 0.5, "looping": false},
	SoundTypes.Sound.CLICK: {"path": "res://assets/sounds/click.ogg", "volume": 0.3, "looping": false}
}

# Sound priority levels
const PRIORITY_HIGH: int = 2
const PRIORITY_NORMAL: int = 1
const PRIORITY_LOW: int = 0

# Audio player pool
var audio_players: Array = []
var player_last_used: Array = []
const AUDIO_PLAYER_POOL_SIZE: int = 8

# Sound cache
var sound_cache: Dictionary = {}
var spell_sound_cache: Dictionary = {}

# Background music
var background_music_player: AudioStreamPlayer = null
var background_track_index: int = 0
var background_tracks: Array = [SoundTypes.Sound.BACKGROUND1, SoundTypes.Sound.BACKGROUND2, SoundTypes.Sound.BACKGROUND3]
var is_background_playing: bool = false

# Volume control
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 0.5

func _ready() -> void:
	print("SoundManager: Initializing autoload singleton")
	create_audio_player_pool()
	create_background_music_player()
	set_process(true)

func create_audio_player_pool() -> void:
	for i in range(AUDIO_PLAYER_POOL_SIZE):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "AudioPlayer_%d" % i
		add_child(player)
		audio_players.append(player)
		player_last_used.append(0)

	print("SoundManager: Created audio player pool with %d players" % AUDIO_PLAYER_POOL_SIZE)

func create_background_music_player() -> void:
	background_music_player = AudioStreamPlayer.new()
	background_music_player.name = "BackgroundMusicPlayer"
	add_child(background_music_player)
	background_music_player.finished.connect(_on_background_music_finished)
	print("SoundManager: Background music player created")

func play_sound(sound_type: SoundTypes.Sound, priority: int = PRIORITY_NORMAL) -> void:
	var config: Dictionary = SOUND_CONFIG.get(sound_type, {})
	if config.is_empty():
		push_warning("SoundManager: Unknown sound type: %d" % sound_type)
		return

	var sound_path: String = config.get("path", "")
	if not ResourceLoader.exists(sound_path):
		return

	var stream: AudioStream = load_sound(sound_path)
	if stream == null:
		return

	var player: AudioStreamPlayer = get_available_player(priority)
	if player == null:
		return

	var sound_volume: float = config.get("volume", 0.3)
	var final_volume: float = sound_volume * sfx_volume * master_volume

	player.stream = stream
	player.volume_db = linear_to_db(final_volume)
	player.play()

	var player_index: int = audio_players.find(player)
	if player_index >= 0:
		player_last_used[player_index] = Time.get_ticks_msec()

func play_spell_sound(spell) -> void:
	if spell == null:
		play_sound(SoundTypes.Sound.MAGIC)
		return

	var spell_class_name: String = ""

	if spell.has_method("get_class"):
		spell_class_name = spell.get_class()
	elif spell is Object and spell.get_script() != null:
		var script: Script = spell.get_script()
		spell_class_name = script.resource_path.get_file().get_basename()

	if spell_class_name.is_empty():
		play_sound(SoundTypes.Sound.MAGIC)
		return

	var sound_path: String = "res://assets/sounds/spells/%s.ogg" % spell_class_name.to_lower()

	if not ResourceLoader.exists(sound_path):
		play_sound(SoundTypes.Sound.MAGIC)
		return

	var stream: AudioStream = load_sound(sound_path)
	if stream == null:
		play_sound(SoundTypes.Sound.MAGIC)
		return

	var player: AudioStreamPlayer = get_available_player(PRIORITY_NORMAL)
	if player == null:
		return

	var final_volume: float = 0.3 * sfx_volume * master_volume

	player.stream = stream
	player.volume_db = linear_to_db(final_volume)
	player.play()

	var player_index: int = audio_players.find(player)
	if player_index >= 0:
		player_last_used[player_index] = Time.get_ticks_msec()

func load_sound(sound_path: String) -> AudioStream:
	if sound_cache.has(sound_path):
		return sound_cache[sound_path]

	if not ResourceLoader.exists(sound_path):
		return null

	var stream: AudioStream = load(sound_path)
	if stream != null:
		sound_cache[sound_path] = stream

	return stream

func get_available_player(priority: int = PRIORITY_NORMAL) -> AudioStreamPlayer:
	for i in range(audio_players.size()):
		var player: AudioStreamPlayer = audio_players[i]
		if not player.playing:
			return player

	if priority >= PRIORITY_HIGH:
		var oldest_index: int = 0
		var oldest_time: int = player_last_used[0]

		for i in range(1, player_last_used.size()):
			if player_last_used[i] < oldest_time:
				oldest_time = player_last_used[i]
				oldest_index = i

		audio_players[oldest_index].stop()
		return audio_players[oldest_index]

	return audio_players[0]

func start_background_music() -> void:
	if is_background_playing:
		return

	background_track_index = 0
	play_next_background_track()

func play_next_background_track() -> void:
	if background_track_index >= background_tracks.size():
		background_track_index = 0

	var track: SoundTypes.Sound = background_tracks[background_track_index]
	var config: Dictionary = SOUND_CONFIG.get(track, {})

	if config.is_empty():
		background_track_index += 1
		return

	var sound_path: String = config.get("path", "")
	if not ResourceLoader.exists(sound_path):
		background_track_index += 1
		return

	var stream: AudioStream = load_sound(sound_path)
	if stream == null:
		background_track_index += 1
		return

	var sound_volume: float = config.get("volume", 0.1)
	var final_volume: float = sound_volume * music_volume * master_volume

	background_music_player.stream = stream
	background_music_player.volume_db = linear_to_db(final_volume)
	background_music_player.play()
	is_background_playing = true

func _on_background_music_finished() -> void:
	is_background_playing = false
	background_track_index += 1
	play_next_background_track()

func stop_background_music() -> void:
	is_background_playing = false
	if background_music_player != null:
		background_music_player.stop()

func set_master_volume(volume: float) -> void:
	master_volume = clampf(volume, 0.0, 1.0)
	update_all_volumes()

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)

func set_music_volume(volume: float) -> void:
	music_volume = clampf(volume, 0.0, 1.0)
	if background_music_player != null and background_music_player.playing:
		var track: SoundTypes.Sound = background_tracks[background_track_index % background_tracks.size()]
		var config: Dictionary = SOUND_CONFIG.get(track, {})
		var sound_volume: float = config.get("volume", 0.1)
		var final_volume: float = sound_volume * music_volume * master_volume
		background_music_player.volume_db = linear_to_db(final_volume)

func update_all_volumes() -> void:
	set_sfx_volume(sfx_volume)
	set_music_volume(music_volume)

func stop_all_sounds() -> void:
	for player in audio_players:
		if player.playing:
			player.stop()

	if background_music_player != null and background_music_player.playing:
		background_music_player.stop()

	is_background_playing = false

func clear_sound_cache() -> void:
	sound_cache.clear()
	spell_sound_cache.clear()
	print("SoundManager: Sound cache cleared")

func get_sound_priority(sound_type: SoundTypes.Sound) -> int:
	match sound_type:
		SoundTypes.Sound.GAMEOVER, SoundTypes.Sound.DEATH:
			return PRIORITY_HIGH
		_:
			return PRIORITY_NORMAL

func play_sound_by_name(sound_name: String) -> void:
	var sound_name_upper: String = sound_name.to_upper()

	for sound_type in SoundTypes.Sound.values():
		var type_name: String = SoundTypes.Sound.keys()[sound_type]
		if type_name == sound_name_upper:
			play_sound(sound_type)
			return

	push_warning("SoundManager: Unknown sound name: %s" % sound_name)

func play_sound_by_enum(sound: Sound) -> void:
	"""
	Plays sound using Sound class configuration.
	Uses the sound's file path, volume, and looping settings.
	"""
	if sound == null:
		push_warning("SoundManager: Cannot play null sound")
		return

	var sound_path: String = sound.get_file()
	if not ResourceLoader.exists(sound_path):
		push_warning("SoundManager: Sound file not found: %s" % sound_path)
		return

	var stream: AudioStream = load_sound(sound_path)
	if stream == null:
		return

	var player: AudioStreamPlayer = get_available_player(PRIORITY_NORMAL)
	if player == null:
		return

	var sound_volume: float = sound.get_volume()
	var final_volume: float = sound_volume * sfx_volume * master_volume

	player.stream = stream
	player.volume_db = linear_to_db(final_volume)
	player.play()

	var player_index: int = audio_players.find(player)
	if player_index >= 0:
		player_last_used[player_index] = Time.get_ticks_msec()

func play_spell_sound_by_class(spell_class_name: String) -> void:
	"""
	Takes spell class name (e.g., "Fireball") and plays the corresponding sound.
	Constructs path: res://assets/sounds/spells/{class_name}.ogg
	Falls back to SoundTypes.Sound.MAGIC if spell-specific sound doesn't exist.
	"""
	if spell_class_name.is_empty():
		play_sound(SoundTypes.Sound.MAGIC)
		return

	# Construct spell sound path
	var sound_path: String = "res://assets/sounds/spells/%s.ogg" % spell_class_name

	# Check if spell-specific sound exists
	if not ResourceLoader.exists(sound_path):
		# Fallback to generic MAGIC sound
		play_sound(SoundTypes.Sound.MAGIC)
		return

	var stream: AudioStream = load_sound(sound_path)
	if stream == null:
		# Fallback to generic MAGIC sound
		play_sound(SoundTypes.Sound.MAGIC)
		return

	var player: AudioStreamPlayer = get_available_player(PRIORITY_NORMAL)
	if player == null:
		return

	# Use standard spell volume (0.3)
	var final_volume: float = 0.3 * sfx_volume * master_volume

	player.stream = stream
	player.volume_db = linear_to_db(final_volume)
	player.play()

	var player_index: int = audio_players.find(player)
	if player_index >= 0:
		player_last_used[player_index] = Time.get_ticks_msec()
