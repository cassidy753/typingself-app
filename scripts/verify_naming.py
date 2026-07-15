#!/usr/bin/env python3
"""Verify the generated naming_engine.dart has all 288 entries."""

import re
from collections import Counter

with open('/Users/ca/Documents/@typingself-app/lib/features/personality_naming/naming_engine.dart') as f:
    content = f.read()

# Count total PersonalityName entries
pattern = r"'([A-Z]+_\d+w\d+)': PersonalityName\("
keys = re.findall(pattern, content)

print(f"Total entries found: {len(keys)}")
print(f"Expected: 288")

# Check for duplicates
dupes = [k for k, v in Counter(keys).items() if v > 1]
if dupes:
    print(f"\n❌ DUPLICATE KEYS FOUND: {dupes}")
else:
    print("✅ No duplicate keys")

# Check each MBTI has 18 entries
mbti_count = Counter(k.split('_')[0] for k in keys)
print(f"\nUnique MBTI types: {len(mbti_count)}")
for m in sorted(mbti_count):
    c = mbti_count[m]
    status = "✅" if c == 18 else "❌"
    print(f"  {status} {m}: {c} entries")

# All 18 enneagrams
enneagrams = sorted(set(k.split('_')[1] for k in keys))
print(f"\nUnique Enneagram types: {len(enneagrams)}")
print(f"  {enneagrams}")

# Check totalEntries getter exists
if 'int get totalEntries => _names.length;' in content:
    print("\n✅ totalEntries getter present")
else:
    print("\n❌ totalEntries getter MISSING")

# Check getName and hasName
if 'getName(String mbti, String enneagram)' in content:
    print("✅ getName method present")
if 'hasName(String mbti, String enneagram)' in content:
    print("✅ hasName method present")
if 'static void addName(PersonalityName name)' in content:
    print("✅ addName method present")

# File size
print(f"\nFile size: {len(content):,} bytes")
print(f"Lines: {content.count(chr(10)):,}")
