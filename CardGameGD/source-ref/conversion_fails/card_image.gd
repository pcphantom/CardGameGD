class_name CardImage
extends Control

## Visual representation of a card on screen
## Replaces CardImage.java from the original game

signal card_clicked(card_visual: CardImage)
signal card_hovered(card_visual: CardImage)
signal card_unhovered(card_visual: CardImage)

# Card data and state
var card: Card = null
var card_type: String = "small"  # "small" or "large"
var is_enabled: bool = true
var is_selected: bool = false
var is_hovered: bool = false
var creature: BaseCreature = null
var spell: BaseSpell = null

# Visual elements
var portrait: TextureRect = null
var name_label: Label = null
var cost_label: Label = null
var attack_label: Label = null
var life_label: Label = null
var frame: TextureRect = null

# Animation state
var is_being_dragged: bool = false
var drag_ghost: Control = null
var original_position: Vector2 = Vector2.ZERO
var original_z_index: int = 0
var hover_tween: Tween = null
var selection_tween: Tween = null
var glow_rect: ColorRect = null

# Size presets
const SMALL_SIZE: Vector2 = Vector2(120, 160)
const LARGE_SIZE: Vector2 = Vector2(180, 240)

# Card type colors
const CARD_COLORS: Dictionary = {
	CardType.Type.FIRE: Color(0.8, 0.2, 0.2),
	CardType.Type.WATER: Color(0.2, 0.2, 0.8),
	CardType.Type.AIR: Color(0.4, 0.7, 1.0),
	CardType.Type.EARTH: Color(0.5, 0.3, 0.1),
	CardType.Type.OTHER: Color(0.6, 0.2, 0.8)
}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	_create_visual_elements()

func _create_visual_elements() -> void:
	# REASON: Cards use only frame texture and artwork texture, no colored backgrounds
	# PROBLEM: Previous code created colored ColorRect backgrounds
	# FIX: Create only frame, portrait, and label elements with proper z-index
	# WHY: Cards must render exactly like original with texture atlas artwork

	# 1. Frame (border) - z_index 0
	frame = TextureRect.new()
	frame.z_index = 0
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)

	# 2. Portrait (artwork) - z_index 1
	portrait = TextureRect.new()
	portrait.z_index = 1
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait)

	# 3. Name label - z_index 5
	name_label = Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.z_index = 5
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(name_label)

	# 4. Stat labels - z_index 10 (highest, always on top)
	cost_label = Label.new()
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost_label.z_index = 10
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cost_label)

	attack_label = Label.new()
	attack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	attack_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	attack_label.z_index = 10
	attack_label.visible = false
	attack_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(attack_label)

	life_label = Label.new()
	life_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	life_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	life_label.z_index = 10
	life_label.visible = false
	life_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(life_label)

func setup_card(card_data: Card, card_size: String = "small") -> void:
	card = card_data
	card_type = card_size

	# Set card size
	var card_dimensions: Vector2 = SMALL_SIZE if card_type == "small" else LARGE_SIZE
	custom_minimum_size = card_dimensions

	# Update visual elements
	update_visual()

func update_visual() -> void:
	# REASON FOR EDIT: Prevent errors when UI elements haven't been created yet
	# PROBLEM: update_visual() can be called before _ready() creates the labels
	# FIX: Return early if card is null OR if labels haven't been created
	# WHY: Trying to set .position on nil label causes "Invalid assignment...Nil" error
	if card == null:
		return

	# Check if visual elements exist (they're created in _ready())
	if cost_label == null or name_label == null or attack_label == null or life_label == null:
		return

	# REASON: Render cards with exact artwork and frame from texture atlas
	# PROBLEM: Previous code used colored backgrounds and incorrect sizing
	# FIX: Use exact pixel dimensions from CardGameGDX and load textures properly
	# WHY: Cards must display actual artwork with proper frames matching original game

	# Determine EXACT sizes based on card type
	var is_large: bool = (card_type == "large")
	var card_width: int = 150 if is_large else 80
	var card_height: int = 207 if is_large else 100
	var frame_width: int = 172 if is_large else 100
	var frame_height: int = 231 if is_large else 111

	# Position and set frame texture - frame extends beyond card edges
	frame.position = Vector2(-11, -12)  # EXACT offset to create border
	frame.size = Vector2(frame_width, frame_height)
	frame.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP

	# Load correct frame based on card type
	if TextureManager and TextureManager.is_loaded:
		if card.is_spell():
			frame.texture = TextureManager.ramka_big_spell if is_large else TextureManager.spell_ramka
		else:
			frame.texture = TextureManager.ramka_big if is_large else TextureManager.ramka

	# Position and set card artwork
	portrait.position = Vector2(0, 0)  # Card artwork at origin
	portrait.size = Vector2(card_width, card_height)
	portrait.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP

	# Load card artwork from texture atlas
	if TextureManager and TextureManager.is_loaded:
		var card_name: String = card.get_name().to_lower()
		var card_texture: Texture2D = null

		if is_large:
			card_texture = TextureManager.get_large_card_texture(card_name)
		else:
			card_texture = TextureManager.get_small_card_texture(card_name)

		if card_texture != null:
			portrait.texture = card_texture
			print("CardImage: Loaded texture for '%s'" % card_name)
		else:
			# Fallback: dark gray if texture missing
			portrait.texture = null
			push_warning("CardImage: Missing texture for card: %s" % card_name)
			# Create dark gray background as fallback
			if portrait.get_child_count() == 0:
				var fallback := ColorRect.new()
				fallback.color = Color(0.15, 0.15, 0.15)
				fallback.size = Vector2(card_width, card_height)
				fallback.z_index = -1
				fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
				portrait.add_child(fallback)

	# Set card visual's overall size to frame size
	custom_minimum_size = Vector2(frame_width, frame_height)
	size = Vector2(frame_width, frame_height)

	# Update name label (hidden for now as original game doesn't show name on card face)
	name_label.text = ""
	name_label.visible = false

	# REASON: Position stats in exact corner coordinates matching CardGameGDX
	# PROBLEM: Stats were positioned in bottom center area, not corners like original
	# FIX: Use exact pixel coordinates from CardDescriptionImage.java
	# WHY: Cards must match original game appearance with corner stat positioning

	# Get stat values
	var cost_value: int = card.get_cost()
	var attack_value: int = 0
	var life_value: int = 0

	if not card.is_spell():
		attack_value = card.get_attack()
		life_value = card.get_life()

	# EXACT stat label positioning for small cards
	if not is_large:
		# Cost (top-right corner) - EXACT position
		var cost_x: float = 70.0 if cost_value < 10 else 68.0
		cost_label.position = Vector2(cost_x, 90.0)
		cost_label.size = Vector2(15, 15)
		cost_label.add_theme_font_size_override("font_size", 12)
		cost_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.0))
		cost_label.text = str(cost_value)
		cost_label.visible = true

		if not card.is_spell():
			# Attack (bottom-left corner) - EXACT position
			var attack_x: float = 5.0 if attack_value < 10 else 3.0
			attack_label.position = Vector2(attack_x, 15.0)
			attack_label.size = Vector2(15, 15)
			attack_label.add_theme_font_size_override("font_size", 12)
			attack_label.add_theme_color_override("font_color", Color(1.0, 0.0, 0.0))
			attack_label.text = str(attack_value)
			attack_label.visible = true

			# Life (bottom-right corner) - EXACT position
			var life_x: float = 73.0 if life_value < 10 else 70.0
			life_label.position = Vector2(life_x, 15.0)
			life_label.size = Vector2(15, 15)
			life_label.add_theme_font_size_override("font_size", 12)
			life_label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.0))
			life_label.text = str(life_value)
			life_label.visible = true
		else:
			attack_label.visible = false
			life_label.visible = false

	# EXACT stat label positioning for large cards
	else:
		# Cost position differs for creatures vs spells
		var cost_x: float = 132.0 if cost_value < 10 else 130.0
		var cost_y: float = 150.0 if not card.is_spell() else 15.0
		cost_label.position = Vector2(cost_x, cost_y)
		cost_label.size = Vector2(18, 18)
		cost_label.add_theme_font_size_override("font_size", 14)
		cost_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.0))
		cost_label.text = str(cost_value)
		cost_label.visible = true

		if not card.is_spell():
			# Attack (bottom-left corner) - EXACT position
			var attack_x: float = 5.0 if attack_value < 10 else 7.0
			attack_label.position = Vector2(attack_x, 15.0)
			attack_label.size = Vector2(18, 18)
			attack_label.add_theme_font_size_override("font_size", 14)
			attack_label.add_theme_color_override("font_color", Color(1.0, 0.0, 0.0))
			attack_label.text = str(attack_value)
			attack_label.visible = true

			# Life (bottom-right corner) - EXACT position
			var life_x: float = 131.0 if life_value < 10 else 134.0
			life_label.position = Vector2(life_x, 15.0)
			life_label.size = Vector2(18, 18)
			life_label.add_theme_font_size_override("font_size", 14)
			life_label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.0))
			life_label.text = str(life_value)
			life_label.visible = true
		else:
			attack_label.visible = false
			life_label.visible = false

	# REASON FOR EDIT: Frame is now TextureRect, use modulate instead of color
	# PROBLEM: TextureRect has no .color property, only ColorRect does
	# FIX: Use .modulate to tint the frame texture
	# WHY: Modulate tints textures to show selection/hover state

	# Update frame tint based on state
	if is_selected:
		frame.modulate = Color.GOLD
	elif is_hovered and is_enabled:
		frame.modulate = Color(1.2, 1.2, 1.2)  # Brightened
	else:
		frame.modulate = Color.WHITE  # Normal

func _get_type_symbol(element_type: int) -> String:
	match element_type:
		CardType.Type.FIRE:
			return "🔥"
		CardType.Type.WATER:
			return "💧"
		CardType.Type.AIR:
			return "💨"
		CardType.Type.EARTH:
			return "🪨"
		CardType.Type.OTHER:
			return "✨"
		_:
			return "•"

func set_enabled(enabled: bool) -> void:
	is_enabled = enabled
	update_visual()

func set_selected(selected: bool) -> void:
	is_selected = selected
	update_visual()

	# Play/stop selection animation
	if selected:
		play_selection_animation()
	else:
		stop_selection_animation()

func get_card() -> Card:
	return card

func set_creature(new_creature: BaseCreature) -> void:
	creature = new_creature
	update_visual()

func get_creature() -> BaseCreature:
	return creature

func set_spell(new_spell: BaseSpell) -> void:
	spell = new_spell

func get_spell() -> BaseSpell:
	return spell

func _gui_input(event: InputEvent) -> void:
	if not is_enabled:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			card_clicked.emit(self)
			accept_event()

func _on_mouse_entered() -> void:
	if not is_enabled:
		return

	is_hovered = true
	update_visual()
	card_hovered.emit(self)

	# Animate hover effect
	play_hover_enter_animation()

func _on_mouse_exited() -> void:
	is_hovered = false
	update_visual()
	card_unhovered.emit(self)

	# Animate hover exit
	play_hover_exit_animation()

func _to_string() -> String:
	if card != null:
		return "CardImage(%s)" % card.get_name()
	return "CardImage(empty)"

# ============================================================================
# ANIMATION METHODS
# ============================================================================

# Card hover effects
func play_hover_enter_animation() -> void:
	# Kill existing tween
	if hover_tween != null and hover_tween.is_valid():
		hover_tween.kill()

	# Create new tween
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	hover_tween.set_ease(Tween.EASE_OUT)
	hover_tween.set_trans(Tween.TRANS_CUBIC)

	# Scale up
	hover_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.15)

	# Raise z-index
	original_z_index = z_index
	z_index += 10

	# Add subtle glow
	_add_glow_effect(Color(1.0, 1.0, 1.0, 0.3))

func play_hover_exit_animation() -> void:
	# Kill existing tween
	if hover_tween != null and hover_tween.is_valid():
		hover_tween.kill()

	# Create new tween
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	hover_tween.set_ease(Tween.EASE_IN)
	hover_tween.set_trans(Tween.TRANS_CUBIC)

	# Scale back
	hover_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

	# Reset z-index
	z_index = original_z_index

	# Remove glow
	_remove_glow_effect()

# Card selection effects
func play_selection_animation() -> void:
	# Kill existing tween
	if selection_tween != null and selection_tween.is_valid():
		selection_tween.kill()

	# Create pulsating border glow
	selection_tween = create_tween()
	selection_tween.set_loops()
	selection_tween.set_parallel(false)

	# Pulsate between yellow and gold
	selection_tween.tween_property(frame, "modulate", Color(1.0, 1.0, 0.5, 1.0), 0.5)
	selection_tween.tween_property(frame, "modulate", Color.GOLD, 0.5)

	# Raise card
	z_index += 5

	# Add yellow border glow
	_add_glow_effect(Color.GOLD)

func stop_selection_animation() -> void:
	# Kill tween
	if selection_tween != null and selection_tween.is_valid():
		selection_tween.kill()

	# Reset frame modulate
	frame.modulate = Color.WHITE

	# Reset z-index
	z_index = original_z_index

	# Remove glow
	_remove_glow_effect()

# Card drag effects
func start_drag_animation() -> void:
	is_being_dragged = true
	original_position = global_position

	# Increase transparency slightly
	modulate.a = 0.8

	# Create ghost at original position
	_create_drag_ghost()

	# Raise card
	z_index += 20

func update_drag_animation(mouse_pos: Vector2, velocity: Vector2) -> void:
	if not is_being_dragged:
		return

	# Smooth follow
	global_position = global_position.lerp(mouse_pos, 0.3)

	# Rotate based on velocity
	var max_rotation: float = deg_to_rad(15)
	var target_rotation: float = clamp(velocity.x * 0.001, -max_rotation, max_rotation)
	rotation = lerp(rotation, target_rotation, 0.2)

func end_drag_animation(target_pos: Vector2) -> void:
	is_being_dragged = false

	# Snap to target with bounce
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	tween.tween_property(self, "global_position", target_pos, 0.3)
	tween.tween_property(self, "rotation", 0.0, 0.3)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)

	# Remove ghost
	_remove_drag_ghost()

	# Reset z-index after animation
	await tween.finished
	z_index = original_z_index

# Card attack animation
func play_attack_animation(target_pos: Vector2) -> void:
	original_position = global_position

	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Move toward target
	tween.tween_property(self, "global_position", target_pos, 0.2)

	# Hold
	tween.tween_interval(0.1)

	# Return to original position
	tween.tween_property(self, "global_position", original_position, 0.2)

	# Spawn particles at contact point
	await get_tree().create_timer(0.2).timeout
	_spawn_attack_particles(target_pos)

func _spawn_attack_particles(pos: Vector2) -> void:
	# Get element color
	var particle_color: Color = CARD_COLORS.get(card.get_type(), Color.WHITE) if card != null else Color.WHITE

	# Create simple particle effect
	for i in range(5):
		var particle := ColorRect.new()
		particle.size = Vector2(4, 4)
		particle.color = particle_color
		particle.global_position = pos
		get_tree().root.add_child(particle)

		# Animate particle
		var angle := randf() * TAU
		var distance := randf_range(20, 50)
		var target := pos + Vector2(cos(angle), sin(angle)) * distance

		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", target, 0.5)
		tween.tween_property(particle, "modulate:a", 0.0, 0.5)

		await tween.finished
		particle.queue_free()

# Card damage effect
func play_damage_animation(_damage: int) -> void:
	# Play damage sound
	if SoundManager:
		SoundManager.play_sound(SoundTypes.Sound.NEGATIVE_EFFECT)

	# Flash red
	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(self, "modulate", Color.RED, 0.05)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3).set_delay(0.05)

	# Shake effect
	var original_pos := position
	var shake_tween := create_tween()
	shake_tween.set_loops(5)

	for i in range(5):
		var offset := Vector2(randf_range(-3, 3), randf_range(-3, 3))
		shake_tween.tween_property(self, "position", original_pos + offset, 0.04)

	shake_tween.tween_property(self, "position", original_pos, 0.04)

# Card heal effect
func play_heal_animation(_heal_amount: int) -> void:
	# Play heal sound
	if SoundManager:
		SoundManager.play_sound(SoundTypes.Sound.POSITIVE_EFFECT)

	# Flash green
	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(self, "modulate", Color.GREEN, 0.05)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3).set_delay(0.05)

	# Upward particles
	_spawn_heal_particles()

func _spawn_heal_particles() -> void:
	for i in range(8):
		var particle := ColorRect.new()
		particle.size = Vector2(3, 3)
		particle.color = Color.GREEN
		particle.global_position = global_position + Vector2(randf_range(0, size.x), size.y)
		get_tree().root.add_child(particle)

		# Animate particle upward
		var target := particle.global_position + Vector2(randf_range(-20, 20), -60)

		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", target, 0.8)
		tween.tween_property(particle, "modulate:a", 0.0, 0.8)

		await tween.finished
		particle.queue_free()

# Card death animation
func play_death_animation() -> void:
	# Play death sound
	if SoundManager:
		SoundManager.play_sound(SoundTypes.Sound.DEATH)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 0.5)

	# Fall and rotate
	tween.tween_property(self, "rotation", deg_to_rad(90), 0.5)
	tween.tween_property(self, "position:y", position.y + 200, 0.5)

	# Spawn death particles
	_spawn_death_particles()

	# Wait for animation to complete
	await tween.finished

	# Queue for deletion
	queue_free()

func _spawn_death_particles() -> void:
	var particle_color: Color = CARD_COLORS.get(card.get_type(), Color.WHITE) if card != null else Color.WHITE

	# Explosion effect
	for i in range(12):
		var particle := ColorRect.new()
		particle.size = Vector2(6, 6)
		particle.color = particle_color
		particle.global_position = global_position + size / 2
		get_tree().root.add_child(particle)

		# Explode outward
		var angle := (i / 12.0) * TAU
		var distance := randf_range(50, 100)
		var target := particle.global_position + Vector2(cos(angle), sin(angle)) * distance

		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "global_position", target, 0.6)
		tween.tween_property(particle, "modulate:a", 0.0, 0.6)
		tween.tween_property(particle, "rotation", randf_range(-PI, PI), 0.6)

		await tween.finished
		particle.queue_free()

# Glow effect helpers
func _add_glow_effect(glow_color: Color) -> void:
	if glow_rect != null:
		return

	glow_rect = ColorRect.new()
	glow_rect.color = glow_color
	glow_rect.position = Vector2(-4, -4)
	glow_rect.size = size + Vector2(8, 8)
	glow_rect.z_index = -1
	glow_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow_rect)

func _remove_glow_effect() -> void:
	if glow_rect != null:
		glow_rect.queue_free()
		glow_rect = null

# Drag ghost helpers
func _create_drag_ghost() -> void:
	if drag_ghost != null:
		return

	drag_ghost = Control.new()
	drag_ghost.custom_minimum_size = size
	drag_ghost.position = original_position
	drag_ghost.modulate = Color(1.0, 1.0, 1.0, 0.3)

	# Create ghost visual (simplified)
	var ghost_bg := ColorRect.new()
	ghost_bg.color = Color(0.5, 0.5, 0.5, 0.3)  # Semi-transparent gray
	ghost_bg.size = size
	drag_ghost.add_child(ghost_bg)

	get_parent().add_child(drag_ghost)

func _remove_drag_ghost() -> void:
	if drag_ghost != null:
		drag_ghost.queue_free()
		drag_ghost = null
