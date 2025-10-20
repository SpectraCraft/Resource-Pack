
import json
import os

def append_rose_gold_case_to_file(path: str) -> None:
    """Open, mutate, and save one JSON model file."""
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)


    cases = data.get("model", {}).get("cases")
    if not isinstance(cases, list):
        print(f"⤬  Skipped (no cases list): {os.path.basename(path)}")
        return


    if any(c.get("when") == "colorful_trims:rose_gold" for c in cases):
        print(f"−  Already has rose_gold: {os.path.basename(path)}")
        return

    base_name = os.path.splitext(os.path.basename(path))[0] 
    new_case = {
        "model": {
            "type": "minecraft:model",
            "model": f"colorful_trims:item/{base_name}_rose_gold_trim"
        },
        "when": "colorful_trims:rose_gold"
    }

    cases.append(new_case)

    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n") 

    print(f"✓  Added rose_gold to {os.path.basename(path)}")

def main() -> None:
    cwd = os.getcwd()
    for fname in os.listdir(cwd):
        if fname.lower().endswith(".json"):
            append_rose_gold_case_to_file(os.path.join(cwd, fname))

if __name__ == "__main__":
    main()
