FZF_NPM_PREVIEW_DEFAULT_OPTS="
  --preview-window wrap
"

FZF_NPM_RUN_PREVIEW_OPTS="
  $FZF_NPM_PREVIEW_DEFAULT_OPTS
  --preview='jq --arg k {} -r \".scripts[\\\$k]\" package.json' 
"

_fzf_complete_npm() {
  local tokens npm_command
  setopt localoptions noshwordsplit noksh_arrays noposixbuiltins
  tokens=(${(z)LBUFFER})

  if [ ${#tokens} -le 2 ]; then
    return
  fi

  if [[ ! -f "package.json" ]]; then
    return
  fi

  npm_command=${tokens[2]}
  case "$npm_command" in
    run)
      _fzf_complete "$FZF_NPM_RUN_PREVIEW_OPTS" "$@" < <(
        jq -r '.scripts | keys[]' < package.json
      )
      return
      ;;
  esac
}
