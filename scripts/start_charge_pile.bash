# 给 bash ~/start_charge_pile.sh 做 Tab 补全。
_charge_pile_opts() {
  printf '%s\n' start stop status restart --no-gui --hadoop --install-autostart --help -h
}

_charge_pile_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  mapfile -t COMPREPLY < <(compgen -W "$(_charge_pile_opts | tr '\n' ' ')" -- "$cur")
}

_charge_pile_is_our_script() {
  local base
  base="$(basename -- "${1:-}" 2>/dev/null || true)"
  [[ "$base" == "start_charge_pile.sh" || "$base" == "start_all.sh" ]]
}

_charge_pile_complete_bash() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  if (( COMP_CWORD >= 2 )) && _charge_pile_is_our_script "${COMP_WORDS[1]-}"; then
    _charge_pile_complete
    return 0
  fi
  mapfile -t COMPREPLY < <(compgen -f -- "$cur")
}

complete -o default -F _charge_pile_complete start_charge_pile.sh
complete -o default -F _charge_pile_complete start_charge_pile
complete -o default -F _charge_pile_complete start_all.sh
[[ -n "${HOME:-}" ]] && complete -o default -F _charge_pile_complete "$HOME/start_charge_pile.sh"

_cp_bash_spec="$(complete -p bash 2>/dev/null || true)"
if [[ -z "$_cp_bash_spec" || "$_cp_bash_spec" == *_charge_pile_complete_bash* ]]; then
  complete -o filenames -o bashdefault -F _charge_pile_complete_bash bash
fi
unset _cp_bash_spec

start_charge_pile() {
  local w="${HOME}/start_charge_pile.sh"
  if [[ -f "$w" ]]; then
    bash "$w" "$@"
    return
  fi
  echo "还没有 $w。先执行："
  echo "  bash /mnt/hgfs/Small_s3/Charge_pile/scripts/install_start_shortcut.sh"
  return 1
}
