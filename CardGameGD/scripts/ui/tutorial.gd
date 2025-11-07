class_name Tutorial
extends Control

## Tutorial system for Spectromancer card game
## Provides step-by-step instructions and game mechanics explanations

# UI references
var title_label: Label = null
var content_label: RichTextLabel = null
var page_label: Label = null
var previous_button: Button = null
var next_button: Button = null
var close_button: Button = null

# Tutorial state
var current_page: int = 0

# Tutorial pages
var pages: Array[Dictionary] = [
	{
		"title": "Welcome to Spectromancer",
		"content": "[b]Welcome, Mage![/b]\n\nSpectromancer is a lane-based card battle game where you duel against opponents using powerful creatures and devastating spells.\n\n[color=yellow]Your goal:[/color] Reduce your opponent's life to 0 while protecting your own.\n\n[color=cyan]In this tutorial, you'll learn:[/color]\n• Game objectives and win conditions\n• Elemental powers and resources\n• Card types (creatures and spells)\n• Combat mechanics\n• Advanced strategies\n\nClick [b]Next[/b] to begin your journey into the world of magical combat!"
	},
	{
		"title": "Game Objective",
		"content": "[b]How to Win[/b]\n\n[color=yellow]Victory Condition:[/color]\nReduce your opponent's life from 50 to 0 to claim victory!\n\n[color=red]Defeat Condition:[/color]\nIf your life reaches 0, you lose the duel.\n\n[b]Starting Resources:[/b]\n• Both players start with 50 life points\n• Each player starts with 1 point in each elemental power\n• Each player draws 5 cards to begin\n\n[b]Turn Structure:[/b]\n1. Draw a card\n2. Gain +1 to all elemental powers\n3. Summon creatures or cast spells\n4. Attack with your creatures\n5. End your turn\n\nThe duel continues until one mage falls!"
	},
	{
		"title": "Elemental Powers",
		"content": "[b]The Five Elements[/b]\n\nElemental powers are your magical resources. Each turn, you gain +1 in all elements.\n\n[color=#FF4D4D]🔥 FIRE[/color] - Aggressive direct damage\n• Fireball spells\n• Burning creatures\n• Quick strikes\n\n[color=#4D9FFF]💧 WATER[/color] - Healing and protection\n• Healing spells\n• Defensive creatures\n• Life restoration\n\n[color=#FFFF4D]💨 AIR[/color] - Speed and control\n• Flying creatures\n• Movement spells\n• Turn manipulation\n\n[color=#996633]🌍 EARTH[/color] - Strength and resilience\n• Tough creatures\n• Damage reduction\n• Powerful attacks\n\n[color=#B3B3B3]⚡ OTHER[/color] - Utility and versatility\n• Special abilities\n• Unique effects\n• Multi-element cards"
	},
	{
		"title": "Card Types - Creatures",
		"content": "[b]Creature Cards[/b]\n\n[color=yellow]What are Creatures?[/color]\nCreatures are summoned to the battlefield and remain there until destroyed. They can attack each turn and have unique abilities.\n\n[b]Creature Stats:[/b]\n[color=red]⚔️ Attack (ATK):[/color] Damage dealt when attacking\n[color=green]❤️ Life (HP):[/color] Health points\n\n[b]Summoning a Creature:[/b]\n1. Select a creature card from your hand\n2. Check if you have enough elemental power\n3. Click on an empty slot on your side\n4. The creature appears and can attack next turn\n\n[b]Combat Rules:[/b]\n• Creatures attack once per turn\n• Both creatures take damage simultaneously\n• If a creature's life reaches 0, it dies\n• Empty slots can be attacked directly (damages player)\n\n[b]Slots:[/b]\nEach player has 6 slots arranged in lanes. Creatures can only attack the opposing slot."
	},
	{
		"title": "Card Types - Spells",
		"content": "[b]Spell Cards[/b]\n\n[color=yellow]What are Spells?[/color]\nSpells are one-time effects that activate immediately and then go to your discard pile.\n\n[b]Spell Categories:[/b]\n\n[color=cyan]Direct Damage:[/color]\n• Deal damage to creatures or players\n• Examples: Fireball, Lightning Bolt\n\n[color=green]Healing & Buffs:[/color]\n• Restore life or boost creatures\n• Examples: Divine Intervention, Enrage\n\n[color=purple]Control & Disruption:[/color]\n• Manipulate the battlefield\n• Examples: Time Stop, Hypnosis\n\n[color=orange]Area Effects:[/color]\n• Affect multiple targets\n• Examples: Flame Wave, Armageddon\n\n[b]Casting Spells:[/b]\n1. Select a spell card from your hand\n2. Pay the elemental cost\n3. Choose targets if required\n4. The spell effect activates immediately\n5. The card is discarded"
	},
	{
		"title": "Summoning Creatures",
		"content": "[b]How to Summon[/b]\n\n[b]Step-by-Step Guide:[/b]\n\n[color=yellow]1. Check Your Resources[/color]\nLook at the card's cost in the top-right corner.\nEach color indicates an elemental requirement.\n\n[color=yellow]2. Select the Card[/color]\nClick on the creature card in your hand.\nAvailable slots will be highlighted.\n\n[color=yellow]3. Choose a Slot[/color]\nClick on an empty slot on your side of the field.\n[color=green]Green highlight[/color] = Valid slot\n[color=red]Red highlight[/color] = Invalid slot\n\n[color=yellow]4. Summon Complete![/color]\nYour elemental powers are reduced by the cost.\nThe creature appears in the selected slot.\n\n[b]Important Rules:[/b]\n• Can't summon if you lack resources\n• Can't summon in occupied slots\n• Can't summon in opponent's slots\n• Newly summoned creatures can attack immediately"
	},
	{
		"title": "Combat & Attacking",
		"content": "[b]Battle Mechanics[/b]\n\n[b]How to Attack:[/b]\n1. It must be your turn\n2. Select one of your creatures\n3. Click the opposing slot to attack\n4. Combat is resolved automatically\n\n[b]Attack Resolution:[/b]\n• If the slot has a creature:\n  - Both creatures deal their ATK to each other\n  - Damage is simultaneous\n  - Creatures with 0 HP die\n\n• If the slot is empty:\n  - Creature's ATK damages the opponent directly\n  - Reduces opponent's life points\n\n[b]Combat Example:[/b]\n[color=cyan]Your Dragon (8 ATK, 6 HP)[/color]\nvs\n[color=red]Enemy Griffin (5 ATK, 7 HP)[/color]\n\n[color=yellow]Result:[/color]\nDragon takes 5 damage → 1 HP remaining\nGriffin takes 8 damage → Dies!\n\n[b]Strategic Tips:[/b]\n• Attack weak creatures to clear them\n• Attack empty slots for direct damage\n• Use spells before attacking"
	},
	{
		"title": "Special Abilities",
		"content": "[b]Creature Special Abilities[/b]\n\nMany creatures have unique abilities that trigger at specific times.\n\n[b]Common Ability Types:[/b]\n\n[color=green]🟢 On Summon:[/color]\nActivates when the creature enters play\nExample: \"When summoned, deal 3 damage to all enemies\"\n\n[color=yellow]🟡 On Death:[/color]\nActivates when the creature dies\nExample: \"When killed, restore 5 life to your mage\"\n\n[color=cyan]🔵 On Attack:[/color]\nActivates when the creature attacks\nExample: \"When attacking, gain +2 ATK this turn\"\n\n[color=purple]🟣 Start of Turn:[/color]\nActivates at the beginning of your turn\nExample: \"At turn start, heal 2 life\"\n\n[color=orange]🟠 End of Turn:[/color]\nActivates at the end of your turn\nExample: \"At turn end, deal 1 damage to opponent\"\n\n[color=red]🔴 Passive:[/color]\nAlways active\nExample: \"This creature has +3 ATK when damaged\"\n\nRead card descriptions carefully to master their abilities!"
	},
	{
		"title": "Strategy Tips",
		"content": "[b]Winning Strategies[/b]\n\n[color=yellow]Resource Management:[/color]\n• Don't spend all powers early\n• Save resources for powerful cards\n• Balance creature and spell usage\n\n[color=yellow]Board Control:[/color]\n• Fill slots to prevent direct attacks\n• Remove threatening enemy creatures\n• Protect weak creatures with positioning\n\n[color=yellow]Life Management:[/color]\n• Don't panic at lower life totals\n• Use healing spells strategically\n• Sometimes offense is the best defense\n\n[color=yellow]Card Advantage:[/color]\n• Draw cards when possible\n• Don't waste spells unnecessarily\n• Consider card trades carefully\n\n[color=yellow]Timing is Everything:[/color]\n• Use spells at optimal moments\n• Attack before casting damage spells\n• Save removal for key threats\n\n[color=yellow]Adapt Your Strategy:[/color]\n• React to opponent's tactics\n• Don't be predictable\n• Learn from each duel"
	},
	{
		"title": "Class Specializations",
		"content": "[b]Mage Classes[/b]\n\nEach mage specializes in one element, gaining unique cards and abilities.\n\n[color=#FF4D4D]🔥 FIRE MAGE - The Pyroclast[/color]\n• Specializes in direct damage\n• Strong early-game aggression\n• Burn spells and fire creatures\n\n[color=#4D9FFF]💧 WATER MAGE - The Tide Caller[/color]\n• Masters of healing and sustain\n• Defensive playstyle\n• Life restoration and protection\n\n[color=#FFFF4D]💨 AIR MAGE - The Storm Weaver[/color]\n• Controls the battlefield tempo\n• Flying creatures and movement\n• Time manipulation spells\n\n[color=#996633]🌍 EARTH MAGE - The Stone Warden[/color]\n• Commands mighty creatures\n• High attack and defense\n• Raw power and resilience\n\n[color=#B3B3B3]⚡ ARCANE MAGE - The Void Seeker[/color]\n• Versatile spellcaster\n• Unique utility abilities\n• Unpredictable effects\n\nEach class has access to neutral cards plus their specialization cards!"
	},
	{
		"title": "Multiplayer Guide",
		"content": "[b]Playing Against Others[/b]\n\n[color=yellow]Connection Types:[/color]\n\n[b]P2P Direct Connection:[/b]\n• Connect directly to another player\n• One player hosts, other joins via IP\n• Low latency, best for local network\n• Port 5000 must be open\n\n[b]WebRTC Matchmaking:[/b]\n• Connect through matchmaking server\n• Join with a Match ID\n• Works across internet\n• No port forwarding needed\n\n[color=yellow]Turn-Based Rules:[/color]\n• Wait for your turn indicator (gold glow)\n• Turn timer shows elapsed time\n• Opponent's moves sync automatically\n• Network events keep game in sync\n\n[color=yellow]Multiplayer Etiquette:[/color]\n• Don't take excessive time per turn\n• Use \"Forfeit\" if you need to leave\n• Good games are won with skill and respect\n\n[b]Network Indicators:[/b]\n• Gold border = Your turn\n• \"Opponent's turn...\" in log\n• Turn timer tracks your time"
	},
	{
		"title": "Game Controls",
		"content": "[b]Keyboard & Mouse Controls[/b]\n\n[color=yellow]Mouse Controls:[/color]\n• [b]Left Click[/b] - Select cards, targets, slots\n• [b]Right Click[/b] - Cancel selection\n• [b]Hover[/b] - Show card tooltips (0.5s delay)\n\n[color=yellow]Keyboard Shortcuts:[/color]\n• [b]ESC[/b] - Pause menu\n• [b]F3[/b] - Toggle FPS counter\n• [b]Space[/b] - End turn (if available)\n\n[color=yellow]UI Elements:[/color]\n• [b]Turn Timer[/b] - Left side, shows elapsed time\n• [b]FPS Counter[/b] - Top-left (F3 to toggle)\n• [b]Log Panel[/b] - Right side, game events\n• [b]Filter Button[/b] - ⚙️ in log panel\n• [b]Auto-scroll[/b] - Checkbox in log panel\n\n[color=yellow]Pause Menu (ESC):[/color]\n• Resume - Continue game\n• Settings - Audio and network config\n• Forfeit - Concede the match\n• Quit to Menu - Exit to main menu\n\n[color=yellow]Card Tooltips:[/color]\nHover over any card for 0.5 seconds to see:\n• Card name and cost\n• Attack and life stats\n• Full ability description"
	},
	{
		"title": "Ready to Play!",
		"content": "[b]You're Ready for Battle![/b]\n\n[color=yellow]Quick Recap:[/color]\n\n✓ Reduce opponent's life to 0\n✓ Gain +1 elemental power each turn\n✓ Summon creatures to defend and attack\n✓ Cast spells for powerful effects\n✓ Creatures attack opposing slots\n✓ Read ability text carefully\n✓ Manage resources wisely\n✓ Adapt your strategy\n\n[color=cyan]Game Modes:[/color]\n• [b]Single Player[/b] - Practice against AI\n• [b]Multiplayer[/b] - Duel other mages\n• [b]Custom Game[/b] - Set your own rules\n\n[color=green]Good luck, Mage![/color]\n\nMay your spells be powerful and your creatures mighty. The arena awaits your challenge!\n\n[center][b]Close this tutorial and begin your first duel![/b][/center]"
	}
]

func _ready() -> void:
	_get_ui_references()
	_connect_signals()
	_update_page()

func _get_ui_references() -> void:
	"""Get references to UI nodes."""
	title_label = get_node("TutorialPanel/MarginContainer/VBoxContainer/TitleLabel")
	content_label = get_node("TutorialPanel/MarginContainer/VBoxContainer/ScrollContainer/ContentLabel")
	page_label = get_node("TutorialPanel/MarginContainer/VBoxContainer/NavigationContainer/PageLabel")
	previous_button = get_node("TutorialPanel/MarginContainer/VBoxContainer/NavigationContainer/PreviousButton")
	next_button = get_node("TutorialPanel/MarginContainer/VBoxContainer/NavigationContainer/NextButton")
	close_button = get_node("TutorialPanel/MarginContainer/VBoxContainer/CloseButton")

func _connect_signals() -> void:
	"""Connect button signals (already done in scene, but can be done here too)."""
	pass  # Connections are in the .tscn file

func _update_page() -> void:
	"""Update the current page content and navigation buttons."""
	if current_page < 0 or current_page >= pages.size():
		current_page = 0

	var page_data: Dictionary = pages[current_page]

	# Update title
	if title_label:
		title_label.text = page_data.get("title", "Tutorial")

	# Update content
	if content_label:
		content_label.text = page_data.get("content", "No content available")
		# Scroll to top
		content_label.scroll_to_line(0)

	# Update page indicator
	if page_label:
		page_label.text = "Page %d of %d" % [current_page + 1, pages.size()]

	# Update button states
	if previous_button:
		previous_button.disabled = (current_page == 0)

	if next_button:
		next_button.disabled = (current_page >= pages.size() - 1)

	# Change "Next" to "Finish" on last page
	if next_button and current_page == pages.size() - 1:
		next_button.text = "Finish"
	elif next_button:
		next_button.text = "Next >"

func _on_previous_pressed() -> void:
	"""Navigate to previous page."""
	if current_page > 0:
		current_page -= 1
		_update_page()
		_play_page_turn_sound()

func _on_next_pressed() -> void:
	"""Navigate to next page, or close if on last page."""
	if current_page < pages.size() - 1:
		current_page += 1
		_update_page()
		_play_page_turn_sound()
	else:
		# Last page, close tutorial
		_on_close_pressed()

func _on_close_pressed() -> void:
	"""Close the tutorial."""
	_play_close_sound()
	queue_free()

func _play_page_turn_sound() -> void:
	"""Play sound effect for page navigation."""
	if SoundManager:
		SoundManager.play_sound(SoundTypes.Sound.CLICK)

func _play_close_sound() -> void:
	"""Play sound effect for closing tutorial."""
	if SoundManager:
		SoundManager.play_sound(SoundTypes.Sound.CLICK)

func _input(event: InputEvent) -> void:
	"""Handle keyboard shortcuts."""
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_left") and not previous_button.disabled:
		_on_previous_pressed()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right") and not next_button.disabled:
		_on_next_pressed()
		get_viewport().set_input_as_handled()

func jump_to_page(page_index: int) -> void:
	"""Jump directly to a specific page."""
	if page_index >= 0 and page_index < pages.size():
		current_page = page_index
		_update_page()

func get_total_pages() -> int:
	"""Get the total number of tutorial pages."""
	return pages.size()

func get_current_page() -> int:
	"""Get the current page number (0-indexed)."""
	return current_page

func _to_string() -> String:
	return "Tutorial(page %d/%d)" % [current_page + 1, pages.size()]
