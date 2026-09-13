echo "== C5: skills state the absent-project.yml fallback =="
for s in plan verify understand; do
  grep -qiE "absent|fallback|if .*project.yml" "global/skills/$s/SKILL.md" \
    && ok "$s skill states fallback" || bad "$s skill missing fallback"
done
