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

# Debug logging - stores messages temporarily
var debug_messages: Array[String] = []

func write_log(message: String):
	debug_messages.append(message)
	print(message)  # Also print to console

	# Save to file immediately on Android
	if OS.get_name() == "Android":
		_save_to_file()

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

func _save_to_file():
	"""Save all debug messages to error_log.txt in Documents."""
	var file_path = "/storage/emulated/0/Documents/error_log.txt"

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		return

	# Write system info
	file.store_line("=== TEXTURE MANAGER DEBUG LOG ===")
	file.store_line("OS: %s" % OS.get_name())
	file.store_line("Godot: %s" % Engine.get_version_info().string)
	file.store_line("Renderer: %s" % ProjectSettings.get_setting("rendering/renderer/rendering_method"))
	file.store_line("VRAM Compression: %s" % ProjectSettings.get_setting("rendering/textures/vram_compression/import_etc2_astc"))
	file.store_line("GPU: %s" % RenderingServer.get_video_adapter_name())
	file.store_line("GPU Vendor: %s" % RenderingServer.get_video_adapter_vendor())
	file.store_line("GPU API: %s" % RenderingServer.get_video_adapter_api_version())
	file.store_line("===================================")
	file.store_line("")

	# Write all debug messages
	for msg in debug_messages:
		file.store_line(msg)

	file.close()

func load_texture_atlas(atlas_path: String, image_path: String) -> Dictionary:
	var atlas_dict: Dictionary = {}

	write_log("[TextureManager] === LOADING ATLAS ===")
	write_log("[TextureManager] Atlas path: %s" % atlas_path)
	write_log("[TextureManager] Image path: %s" % image_path)
	write_log("[TextureManager] OS: %s" % OS.get_name())

	# Check atlas file exists
	var atlas_exists = FileAccess.file_exists(atlas_path)
	write_log("[TextureManager] Atlas file exists: %s" % atlas_exists)
	if not atlas_exists:
		write_log("[TextureManager] ERROR: Atlas file not found: %s" % atlas_path)
		write_log("[TextureManager] FileAccess error: %s" % FileAccess.get_open_error())
		return atlas_dict

	# Check image resource exists
	var image_exists = ResourceLoader.exists(image_path)
	write_log("[TextureManager] Image resource exists: %s" % image_exists)
	if not image_exists:
		write_log("[TextureManager] ERROR: Atlas image not found: %s" % image_path)
		return atlas_dict

	# CRITICAL FIX: Load the atlas texture WITHOUT calling get_image()
	# This allows VRAM compressed textures to work on Android
	write_log("[TextureManager] Attempting to load texture...")
	var atlas_texture: Texture2D = load(image_path)

	if atlas_texture == null:
		write_log("[TextureManager] ERROR: Failed to load atlas image: %s" % image_path)
		return atlas_dict

	write_log("[TextureManager] ✓ Atlas texture loaded successfully")
	write_log("[TextureManager] Texture class: %s" % atlas_texture.get_class())
	write_log("[TextureManager] Texture size: %s" % atlas_texture.get_size())
	write_log("[TextureManager] Texture resource path: %s" % atlas_texture.resource_path)

	# Check if texture is valid
	if atlas_texture.get_width() == 0 or atlas_texture.get_height() == 0:
		write_log("[TextureManager] WARNING: Texture has zero dimensions!")

	# Check texture size limits
	var tex_width = atlas_texture.get_width()
	var tex_height = atlas_texture.get_height()
	if tex_width > 2048 or tex_height > 2048:
		write_log("[TextureManager] WARNING: Texture exceeds 2048x2048 limit! May fail on some devices.")

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

					# Verify AtlasTexture was created properly
					if atlas_tex.atlas == null:
						write_log("[TextureManager] ERROR: AtlasTexture.atlas is null for card: %s" % current_card_name)
					if atlas_tex.get_width() == 0 or atlas_tex.get_height() == 0:
						write_log("[TextureManager] WARNING: AtlasTexture has zero size for card: %s" % current_card_name)

					# NOTE: TGA flip logic removed - TGA atlases must be pre-flipped
					# If TGA textures appear upside-down, flip them in an image editor
					atlas_dict[current_card_name] = atlas_tex
					cards_loaded += 1

					# Debug log first 5 cards AND last 5 cards
					if cards_loaded <= 5:
						write_log("[TextureManager] Card#%d '%s': region=(%d,%d,%d,%d) size=%s" % [cards_loaded, current_card_name, current_x, current_y, current_width, current_height, atlas_tex.get_size()])

	file.close()

	write_log("[TextureManager] Total cards loaded: %d" % cards_loaded)

	# Log sample of card names in dictionary
	if atlas_dict.size() > 0:
		write_log("[TextureManager] Sample card names in atlas:")
		var count = 0
		for card_name in atlas_dict.keys():
			write_log("[TextureManager]   - '%s'" % card_name)
			count += 1
			if count >= 5:
				break
	else:
		write_log("[TextureManager] WARNING: Atlas dictionary is EMPTY!")

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
