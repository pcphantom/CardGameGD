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
# Use the largest/best quality atlases for extraction
# We'll extract from these and generate both HD (300x300 PNG) and SD (150x150 JPG)
ATLAS_CONFIGS = [
    {
        "name": "large",
        "pack_file": "CardGameGD/assets/images/largeCardsPack.txt",
        "image_file": "CardGameGD/assets/images/largeTiles.png",
        "priority": 1  # Use first
    },
    {
        "name": "large_tga",
        "pack_file": "CardGameGD/assets/images/largeTGACardsPack.txt",
        "image_file": "CardGameGD/assets/images/largeTGATiles.png",
        "priority": 2  # Use for cards not in large atlas
    }
]

# Output settings
HD_SIZE = (300, 300)
SD_SIZE = (150, 150)

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

def extract_card(atlas_image, card_info, card_type_map):
    """Extract a single card from atlas and save both HD (PNG) and SD (JPG) versions"""
    card_name = card_info['name']
    x = card_info.get('x', 0)
    y = card_info.get('y', 0)
    width = card_info.get('width', 80)
    height = card_info.get('height', 80)

    # Get card type from map
    card_type = card_type_map.get(card_name, 'other')

    # Extract region from atlas
    card_image = atlas_image.crop((x, y, x + width, y + height))

    # === Create HD version (300x300 PNG) ===
    hd_dir = os.path.join(OUTPUT_BASE, card_type, 'hd')
    os.makedirs(hd_dir, exist_ok=True)

    hd_image = card_image.resize(HD_SIZE, Image.Resampling.LANCZOS)
    hd_path = os.path.join(hd_dir, f"{card_name}.png")
    hd_image.save(hd_path, 'PNG')  # Keep transparency if present

    # === Create SD version (150x150 JPG) ===
    sd_dir = os.path.join(OUTPUT_BASE, card_type, 'sd')
    os.makedirs(sd_dir, exist_ok=True)

    sd_image = card_image.resize(SD_SIZE, Image.Resampling.LANCZOS)

    # Convert RGBA to RGB for JPEG (JPEG doesn't support transparency)
    if sd_image.mode == 'RGBA':
        # Create white background
        background = Image.new('RGB', sd_image.size, (255, 255, 255))
        background.paste(sd_image, mask=sd_image.split()[3])  # Use alpha channel as mask
        sd_image = background
    elif sd_image.mode != 'RGB':
        sd_image = sd_image.convert('RGB')

    sd_path = os.path.join(sd_dir, f"{card_name}.jpg")
    sd_image.save(sd_path, 'JPEG', quality=95)

    return (hd_path, sd_path)

def extract_atlas(config, card_type_map, already_extracted):
    """Extract all cards from a single atlas (skip already extracted cards)"""
    atlas_name = config['name']
    pack_file = config['pack_file']
    image_file = config['image_file']

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
    skipped_count = 0
    for card_info in cards:
        card_name = card_info['name']

        # Skip if already extracted from higher priority atlas
        if card_name in already_extracted:
            skipped_count += 1
            continue

        try:
            hd_path, sd_path = extract_card(atlas_image, card_info, card_type_map)
            already_extracted.add(card_name)
            extracted_count += 1
            # Uncomment for verbose output:
            # print(f"  ✓ {card_name} -> HD: {hd_path}, SD: {sd_path}")
        except Exception as e:
            print(f"  ✗ FAILED: {card_name} - {e}")

    print(f"Extracted {extracted_count} cards from {atlas_name} (skipped {skipped_count} already extracted)")
    return extracted_count

def main():
    print("=== ATLAS CARD EXTRACTION SCRIPT ===")
    print("Extracting BOTH HD (300x300 PNG) and SD (150x150 JPG) versions\n")

    # Load card type mappings
    card_type_map = load_card_type_map()
    if not card_type_map:
        print("ERROR: Failed to load card type map")
        return

    # Extract from atlases in priority order (avoid duplicates)
    total_extracted = 0
    already_extracted = set()

    # Sort configs by priority
    sorted_configs = sorted(ATLAS_CONFIGS, key=lambda x: x['priority'])

    for config in sorted_configs:
        count = extract_atlas(config, card_type_map, already_extracted)
        total_extracted += count

    # Count unique cards from SD directory
    extracted_cards = set()
    for card_type in os.listdir(OUTPUT_BASE):
        sd_dir = os.path.join(OUTPUT_BASE, card_type, 'sd')
        hd_dir = os.path.join(OUTPUT_BASE, card_type, 'hd')

        if os.path.isdir(sd_dir):
            for filename in os.listdir(sd_dir):
                if filename.endswith('.jpg'):
                    card_name = filename[:-4]  # Remove .jpg
                    extracted_cards.add(card_name)

    # Report results
    print("\n=== EXTRACTION COMPLETE ===")
    print(f"Unique cards extracted: {len(extracted_cards)} / 193 expected")
    print(f"Output formats:")
    print(f"  - HD: 300x300 PNG in */hd/ folders")
    print(f"  - SD: 150x150 JPG in */sd/ folders")

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
    print("\nYou can now add frames to both HD and SD versions as needed.")

if __name__ == '__main__':
    main()
