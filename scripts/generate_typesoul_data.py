#!/usr/bin/env python3
"""
Generate typesoul_data.dart from 432 vault TypeSoul markdown files.
Reads all files from the vault directory, parses YAML + sections,
outputs a Dart file with all TypeSoul entries.
"""

import os
import re
import yaml

VAULT_DIR = "/Users/ca/Documents/Ca_vault/09-專案 Projects/TS-@typingself/02-內容 Content Pipeline/型格 TypeSoul"
OUTPUT_FILE = "/Users/ca/Documents/@typingself-app/lib/features/typesoul/typesoul_data.dart"

EXCLUDE_FILES = {
    "TypeSoul_自我驗證系統.md",
    "TypeSoul_驗證系統.md",
    "TypeSoul_驗證系統_v2.md",
    "TypeSoul_驗證系統_v3.md",
    "TypeSoul_驗證系統_v4.md",
    "TypeSoul_驗證系統_v5.md",
    "TypeSoul_驗證系統_v5.1.md",
    "generate_typesoul_expansion.py",
    "v4_驗證結果_ENFJ_ISFJ.md",
    "v5.1_驗證報告_20260716.md",
    "元驗證_v4.md",
    "元驗證_v5_5loops.md",
    "ENFJ_5w4_迭代記錄.md",
    "ENFJ_5w4_驗證結果.md",
    "ISFJ_9w1_驗證結果_v3.md",
}

# Section header patterns
SECTION_PATTERNS = {
    "coreDescription": r"## 📖 核心描述\n(.*?)(?=\n##|\Z)",
    "superpowers": r"## 🎯 超能力\n(.*?)(?=\n##|\Z)",
    "blindspots": r"## ⚠️ 盲點\n(.*?)(?=\n##|\Z)",
    "shadowDescription": r"## 🌑 壓力下既佢[—\-－ ]+(.*?)(?=\n##|\Z)",
    "growthPath": r"## 📈 成長路徑\n(.*?)(?=\n##|\Z)",
    "dailyQuote": r"## 💬 每日一句\n(.*?)(?=\n##|\Z)",
    "roastMode": r"## 😂 寸嘴mode\n(.*?)(?=\n##|\Z)",
}


def parse_frontmatter(content):
    """Parse YAML frontmatter between --- markers."""
    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return None
    return yaml.safe_load(match.group(1))


def parse_section(content, pattern):
    """Extract a section's body using regex, trimming whitespace."""
    match = re.search(pattern, content, re.DOTALL)
    if not match:
        return None
    return match.group(1).strip()


def parse_bullets(text):
    """Parse markdown bullet list into list of Dart-escaped strings."""
    if not text:
        return []
    bullets = re.findall(r"^[-*]\s+(.+)$", text, re.MULTILINE)
    if not bullets:
        # Maybe it's a numbered list
        bullets = re.findall(r"^\d+\.\s+(.+)$", text, re.MULTILINE)
    return [escape_dart(b.strip()) for b in bullets]


def clean_section(s):
    """Clean a section: strip whitespace and trailing markdown separators."""
    if not s:
        return ""
    s = s.strip()
    # Remove trailing `---` separator lines
    s = re.sub(r"\n---+\s*$", "", s)
    # Remove leading `---` separator lines
    s = re.sub(r"^---+\s*\n", "", s)
    return s.strip()


def escape_dart(s):
    """Escape a string for Dart single-quoted string literal.
    Handles: single quotes, backslashes, newlines, dollar signs.
    """
    if s is None:
        return "''"
    s = s.strip()
    # Escape backslashes first
    s = s.replace("\\", "\\\\")
    # Escape single quotes
    s = s.replace("'", "\\'")
    # Escape dollar signs for Dart string interpolation
    s = s.replace("$", "\\$")
    # Replace newlines with \n escape
    s = s.replace("\n", "\\n")
    return f"'{s}'"


def parse_vault_file(filepath):
    """Parse a single vault markdown file into structured data."""
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    fm = parse_frontmatter(content)
    if not fm:
        return None

    # Only process TypeSoul entries
    if fm.get("type") != "typesoul":
        return None

    type_id = fm.get("type_id", "")
    mbti = fm.get("mbti", "")
    enneagram = fm.get("enneagram", "")
    name_canto = fm.get("name_canto", "")
    emoji = fm.get("emoji", "🧠")

    core = parse_section(content, SECTION_PATTERNS["coreDescription"])
    super_text = parse_section(content, SECTION_PATTERNS["superpowers"])
    blind_text = parse_section(content, SECTION_PATTERNS["blindspots"])
    shadow_text = parse_section(content, SECTION_PATTERNS["shadowDescription"])
    growth_text = parse_section(content, SECTION_PATTERNS["growthPath"])
    quote_text = parse_section(content, SECTION_PATTERNS["dailyQuote"])
    roast_text = parse_section(content, SECTION_PATTERNS["roastMode"])

    # Clean sections
    core = clean_section(core or "")
    shadow_full = clean_section(shadow_text or "")
    if shadow_full:
        # Remove the heading line if it bled in
        shadow_full = re.sub(r"^.*?—\s*", "", shadow_full)
    daily_quote = clean_section(quote_text or "")
    roast = clean_section(roast_text or "")

    return {
        "type_id": type_id,
        "mbti": mbti,
        "enneagram": enneagram,
        "name_canto": name_canto,
        "emoji": emoji if emoji else "🧠",
        "core_description": escape_dart(core),
        "superpowers": parse_bullets(super_text) if super_text else [],
        "blindspots": parse_bullets(blind_text) if blind_text else [],
        "shadow_description": escape_dart(shadow_full),
        "growth_path": parse_bullets(growth_text) if growth_text else [],
        "daily_quote": escape_dart(daily_quote),
        "roast_mode": escape_dart(roast),
    }


def generate_dart(entries):
    """Generate the Dart source file content."""
    lines = [
        "// ═══════════════════════════════════════════════════════════════════════",
        "// typesoul_data.dart — Auto-generated from vault TypeSoul markdown files",
        f"// Source: {len(entries)} entries from vault",
        "// ═══════════════════════════════════════════════════════════════════════",
        "",
        "import 'typesoul.dart';",
        "",
        "const List<TypeSoul> allTypeSouls = <TypeSoul>[",
    ]

    for e in entries:
        # Build superpowers list
        sp_list = ", ".join(f"'{s}'" for s in e["superpowers"])
        bp_list = ", ".join(f"'{s}'" for s in e["blindspots"])
        gp_list = ", ".join(f"'{s}'" for s in e["growth_path"])

        lines.append(f"  TypeSoul(")
        lines.append(f"    typeId: '{e['type_id']}',")
        lines.append(f"    mbti: '{e['mbti']}',")
        lines.append(f"    enneagram: '{e['enneagram']}',")
        lines.append(f"    nameCanto: '{e['name_canto']}',")
        lines.append(f"    emoji: '{e['emoji']}',")
        lines.append(f"    coreDescription: {e['core_description']},")
        lines.append(f"    superpowers: <String>[{sp_list}],")
        lines.append(f"    blindspots: <String>[{bp_list}],")
        lines.append(f"    shadowDescription: {e['shadow_description']},")
        lines.append(f"    growthPath: <String>[{gp_list}],")
        lines.append(f"    dailyQuote: {e['daily_quote']},")
        lines.append(f"    roastMode: {e['roast_mode']},")
        lines.append(f"  ),")

    lines.append("];")
    return "\n".join(lines)


def main():
    # Collect vault files
    if not os.path.isdir(VAULT_DIR):
        print(f"ERROR: Vault directory not found: {VAULT_DIR}")
        return False

    files = sorted(os.listdir(VAULT_DIR))
    entries = []

    for fname in files:
        if not fname.endswith(".md"):
            continue
        if fname in EXCLUDE_FILES:
            continue

        fpath = os.path.join(VAULT_DIR, fname)
        entry = parse_vault_file(fpath)
        if entry:
            entries.append(entry)

    if not entries:
        print(f"ERROR: No TypeSoul entries found in {VAULT_DIR}")
        return False

    print(f"Parsed {len(entries)} TypeSoul entries from vault files")

    # Generate Dart file
    dart_content = generate_dart(entries)

    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write(dart_content)

    print(f"Generated: {OUTPUT_FILE} ({len(dart_content)} bytes)")
    print(f"Entries: {len(entries)}")
    return True


if __name__ == "__main__":
    success = main()
    exit(0 if success else 1)
