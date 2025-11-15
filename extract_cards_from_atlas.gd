extends SceneTree
## Atlas Card Extraction Script
## Extracts all cards from atlas files into individual images organized by type
##
## Usage: godot --headless --script extract_cards_from_atlas.gd

const ATLAS_CONFIGS = [
	{
		"name": "small",
		"pack_file": "res://assets/images/smallCardsPack.txt",
		"image_file": "res://assets/images/smallTiles.png",
		"output_size": Vector2i(150, 150)  # Resize from 80x80 to 150x150
	},
	{
		"name": "large",
		"pack_file": "res://assets/images/largeCardsPack.txt",
		"image_file": "res://assets/images/largeTiles.png",
		"output_size": Vector2i(150, 150)  # Resize from 150x207 to 150x150
	},
	{
		"name": "small_tga",
		"pack_file": "res://assets/images/smallTGACardsPack.txt",
		"image_file": "res://assets/images/smallTGATiles.png",
		"output_size": Vector2i(150, 150)
	},
	{
		"name": "large_tga",
		"pack_file": "res://assets/images/largeTGACardsPack.txt",
		"image_file": "res://assets/images/largeTGATiles.png",
		"output_size": Vector2i(150, 150)
	}
]

var card_type_map: Dictionary = {}  # Maps card name -> card type
var extracted_cards: Dictionary = {}  # Tracks which cards were extracted
var total_extracted: int = 0

func _init() -> void:
	print("=== ATLAS CARD EXTRACTION SCRIPT ===")
	print("")

	# Load card type mappings from cards.json
	load_card_type_map()

	# Process each atlas
	for atlas_config in ATLAS_CONFIGS:
		extract_atlas(atlas_config)

	# Report results
	print("")
	print("=== EXTRACTION COMPLETE ===")
	print("Total cards extracted: %d" % total_extracted)
	print("Unique cards: %d / 193 expected" % extracted_cards.size())

	# List any missing cards
	check_missing_cards()

	quit()

func load_card_type_map() -> void:
	print("Loading card type map from cards.json...")

	var json_path = "res://data/cards.json"
	if not FileAccess.file_exists(json_path):
		print("ERROR: cards.json not found!")
		quit(1)
		return

	var file = FileAccess.open(json_path, FileAccess.READ)
	if not file:
		print("ERROR: Failed to open cards.json")
		quit(1)
		return

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	if json.parse(json_text) != OK:
		print("ERROR: Failed to parse cards.json")
		quit(1)
		return

	var data = json.data
	if not data or not data.has("cards"):
		print("ERROR: Invalid cards.json format")
		quit(1)
		return

	# Build map: card name (lowercase) -> card type (lowercase)
	for card_data in data["cards"]:
		var card_name = card_data.get("name", "").to_lower()
		var card_type = card_data.get("type", "").to_lower()

		if card_name.is_empty() or card_type.is_empty():
			continue

		card_type_map[card_name] = card_type

	print("Loaded %d card type mappings" % card_type_map.size())

func extract_atlas(config: Dictionary) -> void:
	var atlas_name = config["name"]
	var pack_file = config["pack_file"]
	var image_file = config["image_file"]
	var output_size = config["output_size"]

	print("")
	print("--- Processing atlas: %s ---" % atlas_name)

	# Load atlas pack file (LibGDX format)
	if not FileAccess.file_exists(pack_file):
		print("WARNING: Pack file not found: %s" % pack_file)
		return

	var pack_data = FileAccess.open(pack_file, FileAccess.READ)
	if not pack_data:
		print("ERROR: Failed to open pack file: %s" % pack_file)
		return

	# Load atlas image
	if not FileAccess.file_exists(image_file):
		print("WARNING: Image file not found: %s" % image_file)
		pack_data.close()
		return

	var atlas_image = Image.load_from_file(image_file)
	if not atlas_image:
		print("ERROR: Failed to load atlas image: %s" % image_file)
		pack_data.close()
		return

	print("Atlas image loaded: %dx%d" % [atlas_image.get_width(), atlas_image.get_height()])

	# Parse pack file and extract cards
	var cards_in_atlas = 0
	var current_card_name = ""
	var current_x = 0
	var current_y = 0
	var current_width = 0
	var current_height = 0

	while not pack_data.eof_reached():
		var line = pack_data.get_line().strip_edges()

		# Skip empty lines and header lines
		if line.is_empty() or line.begins_with("smallTiles") or line.begins_with("largeTiles"):
			continue

		# Card name line (no leading whitespace, no colon)
		if not line.begins_with(" ") and not line.begins_with("\t") and not line.contains(":"):
			# Save previous card if we have one
			if not current_card_name.is_empty():
				extract_card_region(
					atlas_image,
					current_card_name,
					Rect2i(current_x, current_y, current_width, current_height),
					output_size
				)
				cards_in_atlas += 1

			current_card_name = line.to_lower()
			continue

		# Parse property lines
		if line.contains("xy:"):
			var coords = line.replace("xy:", "").strip_edges().split(",")
			if coords.size() >= 2:
				current_x = coords[0].strip_edges().to_int()
				current_y = coords[1].strip_edges().to_int()

		elif line.contains("size:"):
			var sizes = line.replace("size:", "").strip_edges().split(",")
			if sizes.size() >= 2:
				current_width = sizes[0].strip_edges().to_int()
				current_height = sizes[1].strip_edges().to_int()

	# Don't forget the last card
	if not current_card_name.is_empty():
		extract_card_region(
			atlas_image,
			current_card_name,
			Rect2i(current_x, current_y, current_width, current_height),
			output_size
		)
		cards_in_atlas += 1

	pack_data.close()
	print("Extracted %d cards from %s" % [cards_in_atlas, atlas_name])

func extract_card_region(atlas_image: Image, card_name: String, region: Rect2i, output_size: Vector2i) -> void:
	# Get card type from map
	var card_type = card_type_map.get(card_name, "other")

	# Create output directory structure
	var output_dir = "user://extracted_cards/%s/sd" % card_type
	DirAccess.make_dir_recursive_absolute(output_dir)

	# Extract region from atlas
	var card_image = atlas_image.get_region(region)

	# Resize to output size (150x150)
	if card_image.get_size() != output_size:
		card_image.resize(output_size.x, output_size.y, Image.INTERPOLATE_LANCZOS)

	# Save as JPG
	var output_path = "%s/%s.jpg" % [output_dir, card_name]
	var result = card_image.save_jpg(output_path, 0.95)  # 95% quality

	if result == OK:
		extracted_cards[card_name] = card_type
		total_extracted += 1
		# Uncomment for verbose output:
		# print("  ✓ %s -> %s" % [card_name, output_path])
	else:
		print("  ✗ FAILED: %s (error %d)" % [card_name, result])

func check_missing_cards() -> void:
	print("")
	print("Checking for missing cards...")

	var missing_count = 0
	for card_name in card_type_map.keys():
		if not extracted_cards.has(card_name):
			print("  MISSING: %s (type: %s)" % [card_name, card_type_map[card_name]])
			missing_count += 1

	if missing_count == 0:
		print("✓ All cards extracted successfully!")
	else:
		print("✗ %d cards missing" % missing_count)

	# Show extraction locations
	print("")
	print("Cards extracted to:")
	print("  %s" % OS.get_user_data_dir())
	print("")
	print("Copy these to your project:")
	print("  From: %s/extracted_cards/" % OS.get_user_data_dir())
	print("  To:   CardGameGD/assets/images/cards/")
