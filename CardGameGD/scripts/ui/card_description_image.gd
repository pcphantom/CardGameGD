class_name CardDescriptionImage
extends Control

## ============================================================================
## CardDescriptionImage.gd - EXACT translation of CardDescriptionImage.java
## ============================================================================
## Visual display of card details including portrait, frame, stats, name, and description.
## Shows attack/cost/life for creatures, cost only for spells.
## Renders card name and description text to the right of the card image.
##
## Original: src/main/java/org/antinori/cards/CardDescriptionImage.java
## Translation: scripts/ui/card_description_image.gd
##
## ONLY CHANGES FROM JAVA:
## - package → class_name
## - extends Actor → extends Control
## - Sprite → Sprite2D or Texture2D
## - SpriteBatch → CanvasItem drawing
## - BitmapFont → Font
## - Import paths updated to match CardGameGD structure
## ============================================================================

# ============================================================================
# IMPORTS (Java: import statements)
# ============================================================================

## Java: import com.badlogic.gdx.graphics.Color;
## Java: import com.badlogic.gdx.graphics.Texture;
## Java: import com.badlogic.gdx.graphics.g2d.Sprite;
## Java: import com.badlogic.gdx.graphics.g2d.SpriteBatch;
## Java: import com.badlogic.gdx.graphics.g2d.BitmapFont;
## Java: import com.badlogic.gdx.scenes.scene2d.Actor;
## GDScript: Color, Texture2D, Font, Control are built-in

# ============================================================================
# FIELDS (Java: Sprite img; Texture frame; Card card; BitmapFont font;)
# ============================================================================

## Java: Sprite img;
var img: Texture2D = null  # Card portrait image

## Java: Texture frame;
var frame: Texture2D = null  # Card frame image

## Java: Card card;
var card: Card = null  # Card data

## Java: BitmapFont font;
var font: Font = null  # Font for rendering stats and text

# ============================================================================
# CONSTRUCTORS (Java: 3 overloaded constructors)
# ============================================================================

## Java: public CardDescriptionImage(float x, float y)
## Java: public CardDescriptionImage(Sprite img, Card info)
## Java: public CardDescriptionImage(Sprite img, Texture frame, BitmapFont font, Card info, float x, float y)
##
## GDScript combines all three constructors into one with optional parameters
## @param p_img Card portrait sprite/texture
## @param p_frame Card frame texture
## @param p_font Font for rendering text
## @param p_card Card data
## @param p_x X position
## @param p_y Y position
func _init(p_img: Texture2D = null, p_frame: Texture2D = null, p_font: Font = null, p_card: Card = null, p_x: float = 0.0, p_y: float = 0.0) -> void:
	# Determine which constructor pattern was used
	if p_img != null and p_frame != null and p_font != null and p_card != null:
		# Java: Constructor 3 (lines 27-34)
		# Java: this.img = img; this.frame = frame; this.card = info; this.font = font;
		img = p_img
		frame = p_frame
		card = p_card
		font = p_font
		# Java: setX(x); setY(y);
		position.x = p_x
		position.y = p_y
	elif p_img != null and p_card != null:
		# Java: Constructor 2 (lines 22-25)
		# Java: this.img = img; this.card = info;
		img = p_img
		card = p_card
	else:
		# Java: Constructor 1 (lines 17-20)
		# Java: setX(x); setY(y);
		position.x = p_x
		position.y = p_y

# ============================================================================
# DRAW METHOD (Java: public void draw(SpriteBatch batch, float parentAlpha))
# ============================================================================

## Java: public void draw(SpriteBatch batch, float parentAlpha)
## Draws the card description with portrait, frame, stats, name, and description
## @param _batch The sprite batch (not used in Godot - uses _draw() instead)
## @param parentAlpha Parent alpha for transparency
func draw(_batch = null, parentAlpha: float = 1.0) -> void:
	# Java: if (img == null || frame == null || card == null || font == null) { return; } (lines 38-40)
	if img == null or frame == null or card == null or font == null:
		return

	# Java: Color color = getColor(); (line 42)
	# Java: batch.setColor(color.r, color.g, color.b, color.a * parentAlpha); (line 43)
	var color: Color = modulate
	var draw_color := Color(color.r, color.g, color.b, color.a * parentAlpha)

	# CRITICAL FIX: Godot's _draw() uses LOCAL coordinates, not SCREEN coordinates
	# In LibGDX: getX()/getY() returns screen position, batch.draw() uses absolute coords
	# In Godot: position property is handled by scene graph transform automatically
	# Drawing at (position.x, position.y) doubles the offset - WRONG!
	# Must draw at (0, 0) in local space - the position property handles placement
	var x: float = 0.0  # ✅ CORRECT: Local coordinate origin
	var y: float = 0.0  # ✅ CORRECT: Local coordinate origin

	# Java: batch.draw(img, x, y); (line 47)
	draw_texture(img, Vector2(x, y), draw_color)

	# Java: batch.draw(frame, x - 11, y - 12); (line 48)
	draw_texture(frame, Vector2(x - 11, y - 12), draw_color)

	# Java: int at = card.getAttack(); (lines 50-52)
	# Java: int co = card.getCost();
	# Java: int li = card.getLife();
	var at: int = card.getAttack()
	var co: int = card.getCost()
	var li: int = card.getLife()

	# Java: if (!card.isSpell()) { (line 54)
	if not card.isSpell():
		# Java: font.draw(batch, "" + at, (at > 9 ? x + 5 : x + 7), y + 15); (line 55)
		var at_x: float = x + 5 if at > 9 else x + 7
		draw_string(font, Vector2(at_x, y + 15), str(at), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, draw_color)

		# Java: font.draw(batch, "" + co, (co > 9 ? x + 132 : x + 130), y + 150); (line 56)
		var co_x: float = x + 132 if co > 9 else x + 130
		draw_string(font, Vector2(co_x, y + 150), str(co), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, draw_color)

		# Java: font.draw(batch, "" + li, (li > 9 ? x + 131 : x + 134), y + 15); (line 57)
		var li_x: float = x + 131 if li > 9 else x + 134
		draw_string(font, Vector2(li_x, y + 15), str(li), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, draw_color)
	else:
		# Java: font.draw(batch, "" + co, (co > 9 ? x + 132 : x + 130), y + 15); (line 59)
		var co_x: float = x + 132 if co > 9 else x + 130
		draw_string(font, Vector2(co_x, y + 15), str(co), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, draw_color)

	# Java: font.draw(batch, card.getCardname(), x + 190, y + 150); (line 62)
	draw_string(font, Vector2(x + 190, y + 150), card.getCardname(), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, draw_color)

	# Java: font.draw(batch, card.getDesc(), x + 190, y + 125); //should draw this wrapped width of 240 (line 63)
	# Godot Note: Text wrapping handled by draw_string() width parameter (240)
	draw_string(font, Vector2(x + 190, y + 125), card.getDesc(), HORIZONTAL_ALIGNMENT_LEFT, 240, 16, draw_color)

# Override _draw to call draw() method
func _draw() -> void:
	draw(null, 1.0)

# ============================================================================
# GETTER METHODS (Java: public getters)
# ============================================================================

## Java: public Sprite getImg()
## Returns the card portrait image
## @return The portrait sprite/texture
func getImg() -> Texture2D:
	return img

## Java: public Texture getFrame()
## Returns the card frame texture
## @return The frame texture
func getFrame() -> Texture2D:
	return frame

## Java: public Card getCard()
## Returns the card data
## @return The card object
func getCard() -> Card:
	return card

## Java: public BitmapFont getFont()
## Returns the font used for rendering
## @return The bitmap font
func getFont() -> Font:
	return font

# ============================================================================
# SETTER METHODS (Java: public setters)
# ============================================================================

## Java: public void setImg(Sprite img)
## Sets the card portrait image
## @param p_img The portrait sprite/texture
func setImg(p_img: Texture2D) -> void:
	img = p_img
	queue_redraw()

## Java: public void setFrame(Texture frame)
## Sets the card frame texture
## @param p_frame The frame texture
func setFrame(p_frame: Texture2D) -> void:
	frame = p_frame
	queue_redraw()

## Java: public void setCard(Card card)
## Sets the card data
## @param p_card The card object
func setCard(p_card: Card) -> void:
	card = p_card
	queue_redraw()

## Java: public void setFont(BitmapFont font)
## Sets the font for rendering
## @param p_font The bitmap font
func setFont(p_font: Font) -> void:
	font = p_font
	queue_redraw()
