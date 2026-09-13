echo "== C2: installer scaffolds project.yml on fresh install =="
grep -q "project.yml" install.sh && ok "install.sh references project.yml" || bad "install.sh does not scaffold project.yml"
