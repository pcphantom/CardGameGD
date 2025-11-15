#!/usr/bin/env python3
"""
Atlas Card Extraction Script
Extracts all cards from LibGDX atlas files into individual images organized by type

Usage: python3 extract_cards.py
"""

import os
import json
from PIL import Image

# Atlas configurations
ATLAS_CONFIGS = [
    {
        "name": "small",
        "pack_file": "CardGameGD/assets/images/smallCardsPack.txt",
        "image_file": "CardGameGD/assets/images/smallTiles.png",
        "output_size": (150, 150)  # Resize from 80x80 to 150x150
    },
    {
        "name": "large",
        "pack_file": "CardGameGD/assets/images/largeCardsPack.txt",
        "image_file": "CardGameGD/assets/images/largeTiles.png",
        "output_size": (150, 150)  # Resize from 150x207 to 150x150
    },
    {
        "name": "small_tga",
        "pack_file": "CardGameGD/assets/images/smallTGACardsPack.txt",
        "image_file": "CardGameGD/assets/images/smallTGATiles.png",
        "output_size": (150, 150)
    },
    {
        "name": "large_tga",
        "pack_file": "CardGameGD/assets/images/largeTGACardsPack.txt",
        "image_file": "CardGameGD/assets/images/largeTGATiles.png",
        "output_size": (150, 150)
    }
]

OUTPUT_BASE = "CardGameGD/assets/images/cards"

def load_card_type_map():
    """Load card name -> card type mapping from cards.json"""
    print("Loading card type map from cards.json...")

    json_path = "CardGameGD/data/cards.json"
    if not os.path.exists(json_path):
        print(f"ERROR: cards.json not found at {json_path}")
        return {}

    with open(json_path, 'r') as f:
        data = json.load(f)

    if 'cards' not in data:
        print("ERROR: Invalid cards.json format")
        return {}

    # Build map: card name (lowercase) -> card type (lowercase)
    card_type_map = {}
    for card_data in data['cards']:
        card_name = card_data.get('name', '').lower()
        card_type = card_data.get('type', '').lower()

        if card_name and card_type:
            card_type_map[card_name] = card_type

    print(f"Loaded {len(card_type_map)} card type mappings")
    return card_type_map

def parse_atlas_pack(pack_file):
    """Parse LibGDX atlas pack file and return list of card regions"""
    if not os.path.exists(pack_file):
        print(f"WARNING: Pack file not found: {pack_file}")
        return []

    cards = []
    current_card = {}

    with open(pack_file, 'r') as f:
        for line in f:
            line = line.rstrip('\n\r')

            # Skip empty lines and header lines
            if not line.strip() or 'Tiles.png' in line or line.startswith('size:') and not current_card:
                continue

            # Card name line (no leading whitespace, no colon)
            if line and not line[0].isspace() and ':' not in line:
                # Save previous card if we have one
                if current_card.get('name'):
                    cards.append(current_card)

                current_card = {'name': line.strip().lower()}
                continue

            # Parse property lines
            line = line.strip()

            if line.startswith('xy:'):
                coords = line.replace('xy:', '').strip().split(',')
                if len(coords) >= 2:
                    current_card['x'] = int(coords[0].strip())
                    current_card['y'] = int(coords[1].strip())

            elif line.startswith('size:'):
                sizes = line.replace('size:', '').strip().split(',')
                if len(sizes) >= 2:
                    current_card['width'] = int(sizes[0].strip())
                    current_card['height'] = int(sizes[1].strip())

    # Don't forget the last card
    if current_card.get('name'):
        cards.append(current_card)

    return cards

def extract_card(atlas_image, card_info, card_type_map, output_size):
    """Extract a single card from atlas and save to appropriate folder"""
    card_name = card_info['name']
    x = card_info.get('x', 0)
    y = card_info.get('y', 0)
    width = card_info.get('width', 80)
    height = card_info.get('height', 80)

    # Get card type from map
    card_type = card_type_map.get(card_name, 'other')

    # Create output directory
    output_dir = os.path.join(OUTPUT_BASE, card_type, 'sd')
    os.makedirs(output_dir, exist_ok=True)

    # Extract region from atlas
    card_image = atlas_image.crop((x, y, x + width, y + height))

    # Resize to output size (150x150)
    if card_image.size != output_size:
        card_image = card_image.resize(output_size, Image.Resampling.LANCZOS)

    # Convert RGBA to RGB (JPEG doesn't support transparency)
    if card_image.mode == 'RGBA':
        # Create white background
        background = Image.new('RGB', card_image.size, (255, 255, 255))
        background.paste(card_image, mask=card_image.split()[3])  # Use alpha channel as mask
        card_image = background
    elif card_image.mode != 'RGB':
        card_image = card_image.convert('RGB')

    # Save as JPG
    output_path = os.path.join(output_dir, f"{card_name}.jpg")
    card_image.save(output_path, 'JPEG', quality=95)

    return output_path

def extract_atlas(config, card_type_map):
    """Extract all cards from a single atlas"""
    atlas_name = config['name']
    pack_file = config['pack_file']
    image_file = config['image_file']
    output_size = config['output_size']

    print(f"\n--- Processing atlas: {atlas_name} ---")

    # Parse pack file
    cards = parse_atlas_pack(pack_file)
    if not cards:
        print(f"No cards found in {pack_file}")
        return 0

    print(f"Found {len(cards)} cards in pack file")

    # Load atlas image
    if not os.path.exists(image_file):
        print(f"WARNING: Image file not found: {image_file}")
        return 0

    atlas_image = Image.open(image_file)
    print(f"Atlas image loaded: {atlas_image.width}x{atlas_image.height}")

    # Extract each card
    extracted_count = 0
    for card_info in cards:
        try:
            output_path = extract_card(atlas_image, card_info, card_type_map, output_size)
            extracted_count += 1
            # Uncomment for verbose output:
            # print(f"  ✓ {card_info['name']} -> {output_path}")
        except Exception as e:
            print(f"  ✗ FAILED: {card_info['name']} - {e}")

    print(f"Extracted {extracted_count} cards from {atlas_name}")
    return extracted_count

def main():
    print("=== ATLAS CARD EXTRACTION SCRIPT ===\n")

    # Load card type mappings
    card_type_map = load_card_type_map()
    if not card_type_map:
        print("ERROR: Failed to load card type map")
        return

    # Extract from all atlases
    total_extracted = 0
    extracted_cards = set()

    for config in ATLAS_CONFIGS:
        count = extract_atlas(config, card_type_map)
        total_extracted += count

    # Count unique cards
    for card_type in os.listdir(OUTPUT_BASE):
        sd_dir = os.path.join(OUTPUT_BASE, card_type, 'sd')
        if os.path.isdir(sd_dir):
            for filename in os.listdir(sd_dir):
                if filename.endswith('.jpg'):
                    card_name = filename[:-4]  # Remove .jpg
                    extracted_cards.add(card_name)

    # Report results
    print("\n=== EXTRACTION COMPLETE ===")
    print(f"Total extractions: {total_extracted}")
    print(f"Unique cards: {len(extracted_cards)} / 193 expected")

    # Check for missing cards
    print("\nChecking for missing cards...")
    missing = []
    for card_name in card_type_map.keys():
        if card_name not in extracted_cards:
            missing.append(f"{card_name} (type: {card_type_map[card_name]})")

    if missing:
        print(f"✗ {len(missing)} cards missing:")
        for m in missing:
            print(f"  - {m}")
    else:
        print("✓ All cards extracted successfully!")

    print(f"\nCards extracted to: {OUTPUT_BASE}")

if __name__ == '__main__':
    main()
