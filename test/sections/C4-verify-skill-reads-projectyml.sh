echo "== C4: verify skill reads project.yml =="
grep -q "project.yml" global/skills/verify/SKILL.md && ok "verify/SKILL.md references project.yml" || bad "verify/SKILL.md missing project.yml"
grep -q "source_dirs" global/skills/verify/SKILL.md && ok "verify/SKILL.md uses source_dirs" || bad "verify/SKILL.md missing source_dirs"
