class_name CardVisual
extends Control

## Visual representation of a card on screen
## Replaces CardImage.java from the original game

signal card_clicked(card_visual: CardVisual)
signal card_hovered(card_visual: CardVisual)
signal card_unhovered(card_visual: CardVisual)

# Card data and state
var card: Card = null
var card_type: String = "small"  # "small" or "large"
var is_enabled: bool = true
var is_selected: bool = false
var is_hovered: bool = false
var creature: BaseCreature = null
var spell: BaseSpell = null

# Visual elements
var background: ColorRect = null
var portrait: TextureRect = null
var name_label: Label = null
var cost_label: Label = null
var attack_label: Label = null
var life_label: Label = null
var frame: TextureRect = null  # CHANGED: Use TextureRect for proper frame rendering

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
	# REASON FOR EDIT: Use actual frame textures instead of colored rectangles
	# PROBLEM: CardGameGDX uses actual frame images (ramka.png), not colored boxes
	# FIX: Create TextureRect for frame that will load ramka.png textures
	# WHY: Proper card rendering requires actual frame artwork

	# Frame (border) - now uses texture from TextureManager
	frame = TextureRect.new()
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)

	# Background
	background = ColorRect.new()
	background.color = Color(0.2, 0.2, 0.2)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	# Portrait
	portrait = TextureRect.new()
	portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait)

	# Name label
	name_label = Label.new()
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(name_label)

	# Cost label
	cost_label = Label.new()
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost_label.add_theme_font_size_override("font_size", 16)
	cost_label.add_theme_color_override("font_color", Color.YELLOW)
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cost_label)

	# Attack label (creatures only)
	attack_label = Label.new()
	attack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	attack_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	attack_label.add_theme_font_size_override("font_size", 14)
	attack_label.add_theme_color_override("font_color", Color.RED)
	attack_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	attack_label.visible = false
	add_child(attack_label)

	# Life label (creatures only)
	life_label = Label.new()
	life_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	life_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	life_label.add_theme_font_size_override("font_size", 14)
	life_label.add_theme_color_override("font_color", Color.GREEN)
	life_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	life_label.visible = false
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

	var card_size: Vector2 = SMALL_SIZE if card_type == "small" else LARGE_SIZE
	var border_width: float = 2.0

	# REASON FOR EDIT: Load actual frame textures from TextureManager
	# PROBLEM: Frame was just colored rectangle, not using ramka.png assets
	# FIX: Load proper frame texture based on card type and size
	# WHY: CardGameGDX uses actual frame artwork for proper card rendering

	# Update frame with proper texture
	if TextureManager and TextureManager.is_loaded:
		var is_large: bool = (card_type == "large")
		var is_spell: bool = card.is_spell()
		var frame_texture: Texture2D = TextureManager.get_card_frame(is_spell, is_large)
		if frame_texture:
			frame.texture = frame_texture

	frame.position = Vector2.ZERO
	frame.size = card_size

	# Update background
	var bg_color: Color = CARD_COLORS.get(card.get_type(), Color(0.3, 0.3, 0.3))
	if not is_enabled:
		bg_color = bg_color.darkened(0.5)
	elif is_selected:
		bg_color = bg_color.lightened(0.3)
	elif is_hovered:
		bg_color = bg_color.lightened(0.15)

	background.color = bg_color
	background.position = Vector2(border_width, border_width)
	background.size = card_size - Vector2(border_width * 2, border_width * 2)

	# Update portrait with card texture
	var portrait_height: float = card_size.y * 0.5
	portrait.position = Vector2(border_width + 5, border_width + 5)
	portrait.size = Vector2(card_size.x - border_width * 2 - 10, portrait_height - 10)

	# Load card texture from TextureManager
	if TextureManager and TextureManager.is_loaded:
		var card_texture: Texture2D = null
		if card_type == "small":
			card_texture = TextureManager.get_small_card_texture(card.get_name())
		else:
			card_texture = TextureManager.get_large_card_texture(card.get_name())

		if card_texture != null:
			portrait.texture = card_texture
		else:
			# Fallback to colored rectangle if texture not found
			if portrait.texture == null:
				var placeholder_rect := ColorRect.new()
				placeholder_rect.color = Color(0.15, 0.15, 0.15)
				placeholder_rect.position = portrait.position
				placeholder_rect.size = portrait.size
				placeholder_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
				add_child(placeholder_rect)
				move_child(placeholder_rect, portrait.get_index())

	# Update name label
	name_label.text = card.get_name()
	name_label.position = Vector2(border_width + 5, portrait_height + border_width + 5)
	name_label.size = Vector2(card_size.x - border_width * 2 - 10, 30)

	# Update cost label
	# REASON FOR EDIT: Fix shadowed variable warning
	# PROBLEM: "card_type" at line 13 is class member (String: "small"/"large")
	# PROBLEM: Creating local "card_type" (CardType.Type enum) shadows the class member
	# FIX: Rename local variable to "element_type" to avoid shadow
	# WHY: Shadowing causes confusing errors and potential bugs
	var element_type: CardType.Type = card.get_type()
	var card_cost: int = card.get_cost()
	var type_symbol: String = _get_type_symbol(element_type)
	cost_label.text = "%s%d" % [type_symbol, card_cost]
	cost_label.position = Vector2(border_width + 5, card_size.y - 50)
	cost_label.size = Vector2(card_size.x - border_width * 2 - 10, 20)

	# Update creature stats if applicable
	var is_creature: bool = not card.is_spell()
	attack_label.visible = is_creature
	life_label.visible = is_creature

	if is_creature:
		# REASON FOR EDIT: BaseCreature has no get_attack()/get_life() methods
		# PROBLEM: Calling creature.get_attack() and creature.get_life()
		# FIX: Always use card.get_attack() and card.get_life()
		# WHY: Stats are on Card, not on BaseCreature wrapper

		# Attack label (bottom left)
		attack_label.text = "⚔ %d" % card.get_attack()
		attack_label.position = Vector2(border_width + 5, card_size.y - 25)
		attack_label.size = Vector2((card_size.x - border_width * 2 - 10) / 2, 20)

		# Life label (bottom right)
		life_label.text = "♥ %d" % card.get_life()
		life_label.position = Vector2(card_size.x / 2 + 5, card_size.y - 25)
		life_label.size = Vector2((card_size.x - border_width * 2 - 10) / 2, 20)

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
		return "CardVisual(%s)" % card.get_name()
	return "CardVisual(empty)"

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
	ghost_bg.color = background.color if background != null else Color.GRAY
	ghost_bg.size = size
	drag_ghost.add_child(ghost_bg)

	get_parent().add_child(drag_ghost)

func _remove_drag_ghost() -> void:
	if drag_ghost != null:
		drag_ghost.queue_free()
		drag_ghost = null
