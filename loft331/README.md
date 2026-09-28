# Loft 331 — content skills mirror

The **Loft 331 content system lives in [`drg44/loft331-social`](https://github.com/drg44/loft331-social)**:
brand rulebook, voice guide, photos, fonts, logo, HTML templates, the render
pipeline (`tools/social/render.py` and friends) and the authoritative posted log.
That repo is the single source of truth. Nothing here is edited by hand.

This folder **mirrors the two skills and three slash commands** from that repo so
that a session started on `drg44/claude-skills` also uses them (they are copied
into `.claude/skills/` and `.claude/commands/`, which Claude Code auto-loads):

| Copied here | From `loft331-social` |
|---|---|
| `loft331/skills/loft331-image/` → `.claude/skills/loft331-image/` | `.claude/skills/loft331-image/` |
| `loft331/skills/loft331-social/` (incl. `references/`) → `.claude/skills/loft331-social/` | `.claude/skills/loft331-social/` |
| `loft331/commands/loft-image.md`, `loft-cycle.md`, `loft-brand.md` → `.claude/commands/` | `.claude/commands/loft-*.md` |

The skills only carry the *instructions*. Rendering still needs the kit on disk:
`/home/user/loft331-social` (Claude cloud) or `~/loft331-social` (Mac). If it is
missing, `git clone --depth 1 https://github.com/drg44/loft331-social <that path>`
and `cd` into it — the setup section of each SKILL.md says the same.

## Updating

1. Edit in `drg44/loft331-social` first (skills, references, commands). Commit and push there.
2. In this repo run `loft331/sync.sh`. It clones or pulls `loft331-social` to
   `${LOFT_REPO:-$HOME/loft331-social}` (falling back to `/home/user/loft331-social`
   when that exists), copies the skills and commands into `loft331/`, then refreshes
   the auto-loaded copies under `.claude/`.
3. Commit the result here (`chore(loft331): sync skills from loft331-social`).

Never edit `.claude/skills/loft331-*` or `loft331/skills/*` directly: the next sync overwrites them.
