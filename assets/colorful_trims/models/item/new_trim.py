import json
import os

# Base JSON template
base = {
    "parent": "minecraft:item/generated",
    "textures": {
        "layer0": "minecraft:item/chainmail_boots",
        "layer1": "minecraft:trims/items/boots_trim_echo_shard"
    }
}

# Armor materials and types
materials = ["leather", "chainmail", "gold", "iron", "diamond", "netherite"]
armor_types = ["helmet", "chestplate", "leggings", "boots"]

# Output directory (can be changed if needed)
output_dir = os.getcwd()

def generate_filename(material, armor_type):
    return f"{material}_{armor_type}_rose_gold_trim.json"

# Generate entries for all material/type combos
for material in materials:
    for armor_type in armor_types:
        entry = {
            "parent": base["parent"],
            "textures": {
                "layer0": f"minecraft:item/{material}_{armor_type}",
                "layer1": f"minecraft:trims/items/{armor_type}_trim_rose_gold"
            }
        }
        filename = generate_filename(material, armor_type)
        with open(os.path.join(output_dir, filename), "w", encoding="utf-8") as f:
            json.dump(entry, f, indent=2)
        print(f"✓ Created {filename}")

# Special case: turtle_helmet
entry = {
    "parent": base["parent"],
    "textures": {
        "layer0": "minecraft:item/turtle_helmet",
        "layer1": "minecraft:trims/items/helmet_trim_rose_gold"
    }
}
filename = "turtle_helmet_rose_gold.json"
with open(os.path.join(output_dir, filename), "w", encoding="utf-8") as f:
    json.dump(entry, f, indent=2)
print(f"✓ Created {filename}")
