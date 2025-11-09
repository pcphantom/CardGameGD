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

func _ready() -> void:
	print("TextureManager: Initializing")
	load_textures()

func load_textures() -> void:
	# REASON FOR EDIT: Add debug printing for texture loading verification
	# PROBLEM: Need to verify all frame textures load successfully
	# FIX: Print status for each frame texture loaded
	# WHY: User needs to see if files are actually loading from disk

	print("TextureManager: Loading frame textures...")
	# Load frame textures
	ramka = load_texture("res://assets/images/ramka.png")
	print("  - ramka.png: %s" % ("LOADED" if ramka != null else "FAILED"))

	spell_ramka = load_texture("res://assets/images/ramkaspell.png")
	print("  - ramkaspell.png: %s" % ("LOADED" if spell_ramka != null else "FAILED"))

	portrait_ramka = load_texture("res://assets/images/portraitramka.png")
	print("  - portraitramka.png: %s" % ("LOADED" if portrait_ramka != null else "FAILED"))

	ramka_big = load_texture("res://assets/images/ramkabig.png")
	print("  - ramkabig.png: %s" % ("LOADED" if ramka_big != null else "FAILED"))

	ramka_big_spell = load_texture("res://assets/images/ramkabigspell.png")
	print("  - ramkabigspell.png: %s" % ("LOADED" if ramka_big_spell != null else "FAILED"))

	slot_texture = load_texture("res://assets/images/slot.png")
	print("  - slot.png: %s" % ("LOADED" if slot_texture != null else "FAILED"))

	background_texture = load_texture("res://assets/images/background.jpg")
	print("  - background.jpg: %s" % ("LOADED" if background_texture != null else "FAILED"))

	stunned = load_texture("res://assets/images/stunned.png")
	print("  - stunned.png: %s" % ("LOADED" if stunned != null else "FAILED"))

	print("TextureManager: Loading card atlases...")
	# Load card atlases
	small_card_atlas = load_texture_atlas("res://assets/images/smallCardsPack.txt", "res://assets/images/smallTiles.png")
	large_card_atlas = load_texture_atlas("res://assets/images/largeCardsPack.txt", "res://assets/images/largeTiles.png")
	small_tga_card_atlas = load_texture_atlas("res://assets/images/smallTGACardsPack.txt", "res://assets/images/smallTGATiles.png")
	large_tga_card_atlas = load_texture_atlas("res://assets/images/largeTGACardsPack.txt", "res://assets/images/largeTGATiles.png")
	face_card_atlas = load_texture_atlas("res://assets/images/faceCardsPack.txt", "res://assets/images/faceTiles.png")

	is_loaded = true
	print("TextureManager: Atlas loading complete!")
	print("  - Small cards: %d loaded" % small_card_atlas.size())
	print("  - Large cards: %d loaded" % large_card_atlas.size())
	print("  - Face cards: %d loaded" % face_card_atlas.size())
	print("  - Small TGA cards: %d loaded" % small_tga_card_atlas.size())
	print("  - Large TGA cards: %d loaded" % large_tga_card_atlas.size())

func load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	else:
		push_warning("TextureManager: Texture not found: %s" % path)
		return null

func load_texture_atlas(atlas_path: String, image_path: String) -> Dictionary:
	var atlas_dict: Dictionary = {}

	if not FileAccess.file_exists(atlas_path):
		push_warning("TextureManager: Atlas file not found: %s" % atlas_path)
		return atlas_dict

	if not ResourceLoader.exists(image_path):
		push_warning("TextureManager: Atlas image not found: %s" % image_path)
		return atlas_dict

	# Load the atlas image
	var atlas_texture: Texture2D = load(image_path)
	if atlas_texture == null:
		push_error("TextureManager: Failed to load atlas image: %s" % image_path)
		return atlas_dict

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
				if not current_card_name.is_empty() and current_width > 0 and current_height > 0:
					var atlas_tex := AtlasTexture.new()
					atlas_tex.atlas = atlas_texture
					atlas_tex.region = Rect2(current_x, current_y, current_width, current_height)
					atlas_dict[current_card_name] = atlas_tex

	file.close()
	return atlas_dict

func get_small_card_texture(card_name: String) -> Texture2D:
	var key := card_name.to_lower()
	if small_card_atlas.has(key):
		return small_card_atlas[key]
	return null

func get_large_card_texture(card_name: String) -> Texture2D:
	var key := card_name.to_lower()
	if large_card_atlas.has(key):
		return large_card_atlas[key]
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
