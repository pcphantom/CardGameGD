extends Node

## TextureManager Autoload Singleton
## Loads and manages all game textures and texture atlases
## Replaces texture loading from Cards.java

# Card atlases
var small_card_atlas: Dictionary = {}
var large_card_atlas: Dictionary = {}
var small_tga_card_atlas: Dictionary = {}
var large_tga_card_atlas: Dictionary = {}
var face_card_atlas: Dictionary = {}

# Frame textures
var ramka: Texture2D = null
var spell_ramka: Texture2D = null
var portrait_ramka: Texture2D = null
var ramka_big: Texture2D = null
var ramka_big_spell: Texture2D = null
var slot_texture: Texture2D = null

# Background
var background_texture: Texture2D = null

# Card status indicators
var stunned: Texture2D = null

# Loading state
var is_loaded: bool = false

# Debug log file
var log_file: FileAccess = null
var log_path: String = ""

func _init():
	# Set up debug log file in Documents folder (accessible on Android)
	if OS.get_name() == "Android":
		log_path = "/storage/emulated/0/Documents/texture_debug.log"
	else:
		log_path = "user://texture_debug.log"

	log_file = FileAccess.open(log_path, FileAccess.WRITE)
	if log_file:
		write_log("=== TEXTURE MANAGER DEBUG LOG ===")
		write_log("OS: %s" % OS.get_name())
		write_log("Godot Version: %s" % Engine.get_version_info().string)
		write_log("Log Path: %s" % log_path)
		write_log("===================================")
	else:
		push_error("Failed to create log file at: %s" % log_path)

func write_log(message: String):
	if log_file:
		log_file.store_line(message)
		log_file.flush()  # Ensure it's written immediately
	print(message)  # Also print to console

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if log_file:
			write_log("=== CLOSING LOG FILE ===")
			log_file.close()

func _ready() -> void:
	load_textures()

func load_textures() -> void:
	# Load frame textures
	ramka = load_texture("res://assets/images/ramka.png")
	spell_ramka = load_texture("res://assets/images/ramkaspell.png")
	portrait_ramka = load_texture("res://assets/images/portraitramka.png")
	ramka_big = load_texture("res://assets/images/ramkabig.png")
	ramka_big_spell = load_texture("res://assets/images/ramkabigspell.png")
	slot_texture = load_texture("res://assets/images/slot.png")
	background_texture = load_texture("res://assets/images/background.jpg")
	stunned = load_texture("res://assets/images/stunned.png")

	# Load card atlases
	write_log("[TextureManager] ========================================")
	write_log("[TextureManager] STARTING ATLAS LOADING")
	write_log("[TextureManager] ========================================")

	small_card_atlas = load_texture_atlas("res://assets/images/smallCardsPack.txt", "res://assets/images/smallTiles.png")
	write_log("[TextureManager] small_card_atlas entries: %d" % small_card_atlas.size())

	# Load split large card atlases (largeTiles was split into two 2048x2048-compliant files)
	var large_atlas_1 = load_texture_atlas("res://assets/images/largeCardsPack.txt", "res://assets/images/largeTiles1.png")
	write_log("[TextureManager] large_atlas_1 entries: %d" % large_atlas_1.size())

	var large_atlas_2 = load_texture_atlas("res://assets/images/largeCardsPack.txt", "res://assets/images/largeTiles2.png")
	write_log("[TextureManager] large_atlas_2 entries: %d" % large_atlas_2.size())

	# Merge the two large atlases into one dictionary
	large_card_atlas = large_atlas_1.duplicate()
	for key in large_atlas_2:
		large_card_atlas[key] = large_atlas_2[key]
	write_log("[TextureManager] large_card_atlas total entries: %d" % large_card_atlas.size())

	small_tga_card_atlas = load_texture_atlas("res://assets/images/smallTGACardsPack.txt", "res://assets/images/smallTGATiles.png")
	write_log("[TextureManager] small_tga_card_atlas entries: %d" % small_tga_card_atlas.size())

	large_tga_card_atlas = load_texture_atlas("res://assets/images/largeTGACardsPack.txt", "res://assets/images/largeTGATiles.png")
	write_log("[TextureManager] large_tga_card_atlas entries: %d" % large_tga_card_atlas.size())

	face_card_atlas = load_texture_atlas("res://assets/images/faceCardsPack.txt", "res://assets/images/faceTiles.png")
	write_log("[TextureManager] face_card_atlas entries: %d" % face_card_atlas.size())

	write_log("[TextureManager] ========================================")
	write_log("[TextureManager] ALL ATLASES LOADED")
	write_log("[TextureManager] ========================================")

	is_loaded = true

func load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	else:
		write_log("TextureManager: Texture not found: %s" % path)
		return null

func load_texture_atlas(atlas_path: String, image_path: String) -> Dictionary:
	var atlas_dict: Dictionary = {}

	write_log("[TextureManager] === LOADING ATLAS ===")
	write_log("[TextureManager] Atlas path: %s" % atlas_path)
	write_log("[TextureManager] Image path: %s" % image_path)
	write_log("[TextureManager] OS: %s" % OS.get_name())

	if not FileAccess.file_exists(atlas_path):
		push_error("TextureManager: Atlas file not found: %s" % atlas_path)
		return atlas_dict

	if not ResourceLoader.exists(image_path):
		push_error("TextureManager: Atlas image not found: %s" % image_path)
		return atlas_dict

	# CRITICAL FIX: Load the atlas texture WITHOUT calling get_image()
	# This allows VRAM compressed textures to work on Android
	var atlas_texture: Texture2D = load(image_path)
	if atlas_texture == null:
		push_error("TextureManager: Failed to load atlas image: %s" % image_path)
		return atlas_dict

	write_log("[TextureManager] Atlas texture loaded successfully")
	write_log("[TextureManager] Texture class: %s" % atlas_texture.get_class())
	write_log("[TextureManager] Texture size: %s" % atlas_texture.get_size())

	# Parse the atlas text file
	var file := FileAccess.open(atlas_path, FileAccess.READ)
	if file == null:
		push_error("TextureManager: Failed to open atlas file: %s" % atlas_path)
		return atlas_dict

	var current_card_name: String = ""
	var current_x: int = 0
	var current_y: int = 0
	var current_width: int = 0
	var current_height: int = 0
	var cards_loaded: int = 0

	while not file.eof_reached():
		var line := file.get_line()

		# Skip empty lines
		if line.strip_edges().is_empty():
			continue

		# Check if this is a card name (no leading spaces and no colon)
		if not line.begins_with(" ") and not line.begins_with("\t"):
			# Skip format/filter/repeat lines and png filename
			if line.begins_with("format:") or line.begins_with("filter:") or line.begins_with("repeat:") or line.ends_with(".png"):
				continue
			current_card_name = line.strip_edges().to_lower()
			continue

		# Parse properties (they have leading whitespace)
		var trimmed := line.strip_edges()

		# Parse coordinates
		if trimmed.begins_with("xy:"):
			var coords := trimmed.replace("xy:", "").strip_edges().split(",")
			if coords.size() == 2:
				current_x = coords[0].strip_edges().to_int()
				current_y = coords[1].strip_edges().to_int()
		# Parse size
		elif trimmed.begins_with("size:"):
			var size := trimmed.replace("size:", "").strip_edges().split(",")
			if size.size() == 2:
				current_width = size[0].strip_edges().to_int()
				current_height = size[1].strip_edges().to_int()

				# We have all the info we need, create the AtlasTexture
				# CRITICAL: Use AtlasTexture DIRECTLY - do NOT call get_image()
				# AtlasTexture works with VRAM compressed textures on Android
				if not current_card_name.is_empty() and current_width > 0 and current_height > 0:
					var atlas_tex := AtlasTexture.new()
					atlas_tex.atlas = atlas_texture
					atlas_tex.region = Rect2(current_x, current_y, current_width, current_height)

					# NOTE: TGA flip logic removed - TGA atlases must be pre-flipped
					# If TGA textures appear upside-down, flip them in an image editor
					atlas_dict[current_card_name] = atlas_tex
					cards_loaded += 1

					# Debug log first 3 cards
					if cards_loaded <= 3:
						write_log("[TextureManager] Loaded card '%s': region=(%d,%d,%d,%d)" % [current_card_name, current_x, current_y, current_width, current_height])

	file.close()

	write_log("[TextureManager] Total cards loaded: %d" % cards_loaded)
	write_log("[TextureManager] === ATLAS LOADING COMPLETE ===")

	return atlas_dict

func get_small_card_texture(card_name: String) -> Texture2D:
	var key := card_name.to_lower()
	# Check regular atlas first
	if small_card_atlas.has(key):
		return small_card_atlas[key]
	# Fall back to TGA atlas (some cards like "inferno" are only in TGA)
	if small_tga_card_atlas.has(key):
		return small_tga_card_atlas[key]
	return null

func get_large_card_texture(card_name: String) -> Texture2D:
	var key := card_name.to_lower()
	# Check regular atlas first
	if large_card_atlas.has(key):
		return large_card_atlas[key]
	# Fall back to TGA atlas
	if large_tga_card_atlas.has(key):
		return large_tga_card_atlas[key]
	return null

func get_face_texture(card_name: String) -> Texture2D:
	var key := card_name.to_lower()
	if face_card_atlas.has(key):
		return face_card_atlas[key]
	return null

func get_card_frame(is_spell: bool, is_large: bool = false) -> Texture2D:
	if is_large:
		return ramka_big_spell if is_spell else ramka_big
	else:
		return spell_ramka if is_spell else ramka
