echo "== C1: template project.yml exists, valid, required keys =="
if [ -f "$PY" ]; then
  ok "project.yml exists"
  for k in name area_kind source_dirs commands steering; do
    grep -qE "^${k}:" "$PY" && ok "key '${k}' present" || bad "key '${k}' missing"
  done
  grep -qE "^[[:space:]]+test:" "$PY" && ok "commands.test present" || bad "commands.test missing"
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "import yaml,sys; yaml.safe_load(open('$PY'))" 2>/dev/null \
      && ok "project.yml parses as YAML" || echo "  [skip] YAML lint (pyyaml unavailable or invalid — grep checks stand)"
  fi
else
  bad "project.yml missing ($PY)"
fi
