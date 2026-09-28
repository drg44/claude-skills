#!/usr/bin/env bash
# Sync the Loft 331 content skills from drg44/loft331-social into this repo.
#
#   loft331/sync.sh            # clone-or-pull, copy skills + commands, refresh .claude/ copies
#   LOFT_REPO=/path sync.sh    # use a specific checkout of loft331-social
#
# Source of truth is drg44/loft331-social. Edit there first, then re-run this.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"          # <repo>/loft331
ROOT="$(cd "$HERE/.." && pwd)"                                  # <repo>
UPSTREAM_URL="https://github.com/drg44/loft331-social"

# Where loft331-social lives: $LOFT_REPO > ~/loft331-social > /home/user/loft331-social (cloud)
LOFT_REPO="${LOFT_REPO:-$HOME/loft331-social}"
if [ ! -d "$LOFT_REPO/.git" ] && [ -d /home/user/loft331-social/.git ]; then
  LOFT_REPO=/home/user/loft331-social
fi

if [ -d "$LOFT_REPO/.git" ]; then
  echo "→ pulling $LOFT_REPO"
  git -C "$LOFT_REPO" pull --ff-only --quiet || echo "  (pull failed — using the checkout as-is)"
else
  echo "→ cloning $UPSTREAM_URL → $LOFT_REPO"
  git clone --depth 1 "$UPSTREAM_URL" "$LOFT_REPO"
fi

SRC_SKILLS="$LOFT_REPO/.claude/skills"
SRC_CMDS="$LOFT_REPO/.claude/commands"
for d in "$SRC_SKILLS/loft331-image" "$SRC_SKILLS/loft331-social"; do
  [ -f "$d/SKILL.md" ] || { echo "missing $d/SKILL.md in $LOFT_REPO" >&2; exit 1; }
done

# 1. Mirror into loft331/skills and loft331/commands (full replace, so deletions propagate).
rm -rf "$HERE/skills" "$HERE/commands"
mkdir -p "$HERE/skills" "$HERE/commands"
cp -R "$SRC_SKILLS/loft331-image"  "$HERE/skills/loft331-image"
cp -R "$SRC_SKILLS/loft331-social" "$HERE/skills/loft331-social"
cp "$SRC_CMDS"/loft-*.md "$HERE/commands/"
find "$HERE/skills" -name '.DS_Store' -delete 2>/dev/null || true

# 2. Make sure each SKILL.md tells a session how to get the kit on disk.
#    Idempotent: only inserted when the clone hint is absent.
python3 - "$HERE/skills/loft331-image/SKILL.md" "$HERE/skills/loft331-social/SKILL.md" <<'PY'
import re, sys
HINT = ("The repo `drg44/loft331-social` must be on disk: cloud → `/home/user/loft331-social`, "
        "Mac → `~/loft331-social`. If that path is missing, run "
        "`git clone --depth 1 https://github.com/drg44/loft331-social <that path>` first, then `cd` into it.")
for path in sys.argv[1:]:
    text = open(path, encoding="utf-8").read()
    if "git clone --depth 1 https://github.com/drg44/loft331-social" in text:
        continue
    # Insert right after the first "Everything lives in this repo" / setup paragraph, else after the H1.
    m = re.search(r"^\*\*Everything lives in this repo.*?$", text, re.M)
    if m:
        text = text[:m.end()] + "\n\n" + HINT + text[m.end():]
    else:
        m = re.search(r"^# .*$", text, re.M)
        text = text[:m.end()] + "\n\n## 0. Setup\n" + HINT + text[m.end():]
    open(path, "w", encoding="utf-8").write(text)
    print(f"  + setup hint added to {path}")
PY

# 3. Refresh the auto-loaded copies (real directories, not symlinks).
mkdir -p "$ROOT/.claude/skills" "$ROOT/.claude/commands"
for s in loft331-image loft331-social; do
  rm -rf "$ROOT/.claude/skills/$s"
  cp -R "$HERE/skills/$s" "$ROOT/.claude/skills/$s"
done
cp "$HERE/commands"/loft-*.md "$ROOT/.claude/commands/"

echo "✓ synced from $LOFT_REPO ($(git -C "$LOFT_REPO" rev-parse --short HEAD))"
find "$HERE/skills" "$HERE/commands" "$ROOT/.claude/skills/loft331-image" "$ROOT/.claude/skills/loft331-social" -type f | sort
ls "$ROOT/.claude/commands"/loft-*.md
