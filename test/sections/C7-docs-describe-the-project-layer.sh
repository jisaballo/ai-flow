echo "== C7: docs describe the project layer =="
grep -rq "project.yml" docs/ && ok "docs mention project.yml" || bad "docs do not mention project.yml"
