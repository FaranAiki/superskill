import json
import os

keys_to_add = {
    "abacusGame": "Abacus Game",
    "abacusGameDesc": "Learn and calculate using a virtual abacus",
    "abacusSettings": "Abacus Settings",
    "columns": "Columns",
    "gameMode": "Game Mode",
    "abacusToNumber": "Abacus -> Number",
    "numberToAbacus": "Number -> Abacus",
    "submit": "Submit"
}

filepath = "lib/l10n/app_zh.arb"
if os.path.exists(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Add missing keys
    for k, v in keys_to_add.items():
        if k not in data:
            data[k] = v
    
    # Save it back formatting properly
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    print(f"Updated {filepath}")

