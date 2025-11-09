class_name ActionMoveCircular
extends Tween

## ============================================================================
## ActionMoveCircular.gd - EXACT translation of ActionMoveCircular.java
## ============================================================================
## Action that moves an actor in a circular or elliptical path.
## Uses trigonometry to calculate position at each time step.
## Supports both circular (equal radii) and elliptical (different radii) motion.
##
## Original: src/main/java/org/antinori/cards/ActionMoveCircular.java
## Translation: scripts/actions/action_move_circular.gd
##
## ONLY CHANGES FROM JAVA:
## - package → class_name
## - extends TemporalAction → extends Tween (Godot's temporal action system)
## - Static factory methods preserved
## - Interpolation → Tween.TransitionType/EaseType
## - Import paths updated to match CardGameGD structure
## ============================================================================

# ============================================================================
# IMPORTS (Java: import statements)
# ============================================================================

## Java: import com.badlogic.gdx.math.Interpolation;
## Java: import com.badlogic.gdx.scenes.scene2d.actions.TemporalAction;
## GDScript: Tween is built-in, provides interpolation

# ============================================================================
# FIELDS (Java: private float fields)
# ============================================================================

## Java: private float startX, startY;
var startX: float = 0.0
var startY: float = 0.0

## Java: private float r1;
var r1: float = 0.0  # First radius (horizontal for ellipse)

## Java: private float r2;
var r2: float = 0.0  # Second radius (vertical for ellipse)

# Actor reference (in Godot, we track the node being animated)
var actor: Node2D = null

# Duration and interpolation tracking
var duration: float = 1.0
var interpolation_type: Tween.TransitionType = Tween.TRANS_LINEAR

# ============================================================================
# STATIC FACTORY METHODS (Java: public static ActionMoveCircular methods)
# ============================================================================

## Java: public static ActionMoveCircular actionCircle(float x, float y, float r, float duration)
## Creates a circular motion action with linear interpolation
## @param x Center X position
## @param y Center Y position
## @param r Radius
## @param duration Duration in seconds
## @return New ActionMoveCircular instance
static func actionCircle(x: float, y: float, r: float, p_duration: float) -> ActionMoveCircular:
	# Java: return ActionMoveCircular.actionEllipse(x, y, r, r, duration, Interpolation.linear); (line 12)
	return ActionMoveCircular.actionEllipse(x, y, r, r, p_duration, Tween.TRANS_LINEAR)

## Java: public static ActionMoveCircular actionCircle(float x, float y, float r, float duration, Interpolation interpolation)
## Creates a circular motion action with specified interpolation
## @param x Center X position
## @param y Center Y position
## @param r Radius
## @param p_duration Duration in seconds
## @param p_interpolation Interpolation type
## @return New ActionMoveCircular instance
static func actionCircleWithInterpolation(x: float, y: float, r: float, p_duration: float, p_interpolation: Tween.TransitionType) -> ActionMoveCircular:
	# Java: return ActionMoveCircular.actionEllipse(x, y, r, r, duration, Interpolation.linear); (line 16)
	# Note: Java code has bug - ignores interpolation parameter, always uses linear
	return ActionMoveCircular.actionEllipse(x, y, r, r, p_duration, Tween.TRANS_LINEAR)

## Java: public static ActionMoveCircular actionEllipse(float x, float y, float r1, float r2, float duration)
## Creates an elliptical motion action with linear interpolation
## @param x Center X position
## @param y Center Y position
## @param p_r1 First radius (horizontal)
## @param p_r2 Second radius (vertical)
## @param p_duration Duration in seconds
## @return New ActionMoveCircular instance
static func actionEllipse(x: float, y: float, p_r1: float, p_r2: float, p_duration: float, p_interpolation: Tween.TransitionType = Tween.TRANS_LINEAR) -> ActionMoveCircular:
	# Java: ActionMoveCircular action = new ActionMoveCircular(); (line 24)
	var action := ActionMoveCircular.new()

	# Java: action.setR(r1, r2); (line 25)
	action.setR(p_r1, p_r2)

	# Java: action.setDuration(duration); (line 26)
	action.setDuration(p_duration)

	# Java: action.setPosition(x, y); (line 27)
	action.setPosition(x, y)

	# Java: action.setInterpolation(interpolation); (line 28)
	action.setInterpolation(p_interpolation)

	# Java: return action; (line 29)
	return action

# ============================================================================
# CONFIGURATION METHODS (Java: protected/public setters)
# ============================================================================

## Java: protected void setPosition(float x, float y)
## Sets the center position of the circular/elliptical path
## @param x Center X position
## @param y Center Y position
func setPosition(x: float, y: float) -> void:
	# Java: startX = x; startY = y; (lines 33-34)
	startX = x
	startY = y

## Java: public void setR(float r1, float r2)
## Sets the radii for elliptical motion
## @param p_r1 First radius (horizontal)
## @param p_r2 Second radius (vertical)
func setR(p_r1: float, p_r2: float) -> void:
	# Java: this.r1 = r1; this.r2 = r2; (lines 47-48)
	r1 = p_r1
	r2 = p_r2

## Sets the duration of the action
## @param p_duration Duration in seconds
func setDuration(p_duration: float) -> void:
	duration = p_duration

## Sets the interpolation type
## @param p_interpolation Interpolation type
func setInterpolation(p_interpolation: Tween.TransitionType) -> void:
	interpolation_type = p_interpolation

# ============================================================================
# ACTION EXECUTION METHODS (Java: protected methods)
# ============================================================================

## Java: protected void begin()
## Called when action begins - empty in Java
func begin() -> void:
	# Empty in Java (lines 37-39)
	pass

## Java: protected void update(float percent)
## Updates the actor's position along the circular/elliptical path
## @param percent Completion percentage (0.0 to 1.0)
func update(percent: float) -> void:
	# Java: float angle = (float) (Math.PI * 2 * (percent / 1f)); (line 42)
	var angle: float = PI * 2.0 * percent

	# Java: actor.setPosition(startX + r1 * (float) Math.cos(angle), startY + r2 * (float) Math.sin(angle)); (line 43)
	if actor:
		actor.position.x = startX + r1 * cos(angle)
		actor.position.y = startY + r2 * sin(angle)

# ============================================================================
# CONVENIENCE METHOD FOR GODOT
# ============================================================================

## Starts the circular/elliptical motion on a target node
## @param target The node to animate
func start(target: Node2D) -> void:
	actor = target
	begin()

	# Use Godot's built-in method_track to call update() over time
	# Note: target must be a Node to create tweens
	if target.has_method("create_tween"):
		var tween := target.create_tween()
		tween.set_trans(interpolation_type)
		tween.tween_method(update, 0.0, 1.0, duration)
