#!/usr/bin bash

# Netlify bash completion file. Generated with:
# netlify completion:generate --shell=bash > netlify

# You need to put that "netlify" file in one of the following directories (depending on your system):
 
# - $XDG_DATA_HOME/bash-completion/completions
# - ~/.local/share/bash-completion/completions
# - /usr/local/share/bash-completion/completions
 # - /usr/share/bash-completion/completions
 
# Usually this should work:
 
# $ netlify completion:generate --shell=bash | tee ~/.local/share/bash-completion/completions/netlify
 
# Also, 'netlify' provides the alias: 'ntl'. You can generate completion script for that using the "completion:generate:alias" command. 

# For example:

# $ netlify completion:generate:alias --shell=bash ntl | tee ~/.local/share/bash-completion/completions/ntl 

__netlify_debug()
{
  if [[ -n ${BASH_COMP_DEBUG_FILE} ]]; then
    echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
  fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__netlify_init_completion()
{
  COMPREPLY=()
  _get_comp_words_by_ref "$@" cur prev words cword
}

__netlify_index_of_word()
{
  local w word=$1
  shift
  index=0
  for w in "$@"; do
    [[ $w = "$word" ]] && return
    index=$((index+1))
  done
  index=-1
}

__netlify_contains_word()
{
  local w word=$1; shift
  for w in "$@"; do
      [[ $w = "$word" ]] && return
  done
  return 1
}

__netlify_filter_flag()
{
  local flag

  for inserted_flag in "${inserted_flags[@]}"; do
    for i in "${!COMPREPLY[@]}"; do
      flag="${COMPREPLY[i]%%=*}"
      if [[ $flag = $inserted_flag ]]; then
        if ! __netlify_contains_word $flag "${multi_flags[@]}"; then
          __netlify_debug "${FUNCNAME[0]}: ${COMPREPLY[i]}"
          unset 'COMPREPLY[i]'
        fi
      fi
    done
  done

  COMPREPLY=("${COMPREPLY[@]}")
}

__netlify_handle_reply()
{
  local comp

  __netlify_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]} cur is $cur"

  case $cur in
    -*)
      if [[ $(type -t compopt) = "builtin" ]]; then
        compopt -o nospace
      fi

      local allflags=("${flags[*]}")

      while IFS='' read -r comp; do
        COMPREPLY+=("$comp")
      done < <(compgen -W "${allflags[*]}" -- "$cur")

      if [[ $(type -t compopt) = "builtin" ]]; then
        [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
      fi

      __netlify_filter_flag

      # complete after --flag=abc
      if [[ $cur == *=* ]]; then
        COMPREPLY=()

        if [[ $(type -t compopt) = "builtin" ]]; then
          compopt +o nospace
        fi

        local index flag
        flag="${cur%%=*}"
        __netlify_index_of_word "$flag" "${option_flags[@]}"

        __netlify_debug "${FUNCNAME[0]}: flag is $flag index is $index"

        if [[ ${index} -ge 0 ]]; then
          cur="${cur#*=}"

          local option_flag_handler="${option_flag_handlers[${index}]}"
          $option_flag_handler
        fi
      fi

      return
      ;;
  esac

  local index
  __netlify_index_of_word "$prev" "${option_flags[@]}"

  __netlify_debug "${FUNCNAME[0]}: flag is $flag index is $index"

  if [[ ${index} -ge 0 ]]; then
    local option_flag_handler="${option_flag_handlers[${index}]}"
    $option_flag_handler
    return
  fi

  local completions

  completions=("${commands[@]}")

  while IFS='' read -r comp; do
    COMPREPLY+=("$comp")
  done < <(compgen -W "${completions[*]}" -- "$cur")

  __netlify_filter_flag

  # available in bash-completion >= 2, not always present on macOS
  if declare -F __ltrim_colon_completions >/dev/null; then
    __ltrim_colon_completions "$cur"
  fi

  # If there is only 1 completion and it is a flag with an = it will be completed
  # but we don't want a space after the =
  if [[ "${#COMPREPLY[@]}" -eq "1" ]] && [[ $(type -t compopt) = "builtin" ]] && [[ "${COMPREPLY[0]}" == --*= ]]; then
     compopt -o nospace
  fi
}

__netlify_handle_flag()
{

  __netlify_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

  # skip the argument to option flag without =
  if [[ ${words[c]} != *"="* ]] && __netlify_contains_word "${words[c]}" "${option_flags[@]}"; then
    __netlify_debug "${FUNCNAME[0]}: found a flag ${words[c]}, skip the next argument"

    c=$((c+1))

    # if we are looking for a flags value, don't show commands
    if [[ $c -eq $cword ]]; then
      commands=()
    fi
  fi

  c=$((c+1))
}

__netlify_handle_command()
{
  __netlify_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

  local next_command
  if [[ -n ${last_command} ]]; then
    next_command="_${last_command}_${words[c]//:/__}"
  else
    if [[ $c -eq 0 ]]; then
      next_command="_netlify"
    else
      next_command="_${words[c]//:/__}"
    fi
  fi

  c=$((c+1))

  __netlify_debug "${FUNCNAME[0]}: looking for ${next_command}"

  declare -F "$next_command" >/dev/null && $next_command
}

__netlify_handle_word()
{
  __netlify_debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    if __netlify_contains_word "${words[c]}" "${command_aliases[@]}"; then
      __netlify_debug "${FUNCNAME[0]}: words[c] is ${words[c]} -> ${command_by_alias[${words[c]}]}"

      words[c]=${command_by_alias[${words[c]}]}
    fi
  fi

  if [[ $c -ge $cword ]]; then
    __netlify_handle_reply

    __netlify_debug "${FUNCNAME[0]}: COMPREPLY is ${COMPREPLY[@]}"
    return
  fi

  if [[ "${words[c]}" == -* ]]; then
    __netlify_handle_flag
  elif __netlify_contains_word "${words[c]}" "${commands[@]}"; then
    __netlify_handle_command
  elif __netlify_contains_word "${words[c]}" "${command_aliases[@]}"; then
    __netlify_handle_command
  elif [[ $c -eq 0 ]]; then
    __netlify_handle_command
  else
    c=$((c+1))
  fi

  __netlify_handle_word
}


_netlify_addons()
{
  last_command=netlify_addons
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
}

_netlify_addons__auth()
{
  last_command=netlify_addons__auth
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_addons__config()
{
  last_command=netlify_addons__config
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_addons__create()
{
  last_command=netlify_addons__create
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_addons__delete()
{
  last_command=netlify_addons__delete
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--force")
  flags+=("-f")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_addons__list()
{
  last_command=netlify_addons__list
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--json")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_api()
{
  last_command=netlify_api
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--data")
  flags+=("-d")
  multi_flags+=("--data")
  multi_flags+=("-d")
  flags+=("--list")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_build()
{
  last_command=netlify_build
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--dry")
  flags+=("--context")
  multi_flags+=("--context")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_deploy()
{
  last_command=netlify_deploy
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--dir")
  flags+=("-d")
  multi_flags+=("--dir")
  multi_flags+=("-d")
  flags+=("--functions")
  flags+=("-f")
  multi_flags+=("--functions")
  multi_flags+=("-f")
  flags+=("--prod")
  flags+=("-p")
  flags+=("--prodIfUnlocked")
  flags+=("--alias")
  multi_flags+=("--alias")
  flags+=("--branch")
  flags+=("-b")
  multi_flags+=("--branch")
  multi_flags+=("-b")
  flags+=("--open")
  flags+=("-o")
  flags+=("--message")
  flags+=("-m")
  multi_flags+=("--message")
  multi_flags+=("-m")
  flags+=("--auth")
  flags+=("-a")
  multi_flags+=("--auth")
  multi_flags+=("-a")
  flags+=("--site")
  flags+=("-s")
  multi_flags+=("--site")
  multi_flags+=("-s")
  flags+=("--json")
  flags+=("--timeout")
  multi_flags+=("--timeout")
  flags+=("--trigger")
  flags+=("--build")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_dev()
{
  last_command=netlify_dev
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--command")
  flags+=("-c")
  multi_flags+=("--command")
  multi_flags+=("-c")
  flags+=("--port")
  flags+=("-p")
  multi_flags+=("--port")
  multi_flags+=("-p")
  flags+=("--targetPort")
  multi_flags+=("--targetPort")
  flags+=("--dir")
  flags+=("-d")
  multi_flags+=("--dir")
  multi_flags+=("-d")
  flags+=("--functions")
  flags+=("-f")
  multi_flags+=("--functions")
  multi_flags+=("-f")
  flags+=("--offline")
  flags+=("-o")
  flags+=("--live")
  flags+=("-l")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_dev__exec()
{
  last_command=netlify_dev__exec
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_dev__trace()
{
  last_command=netlify_dev__trace
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--request")
  flags+=("-X")
  multi_flags+=("--request")
  multi_flags+=("-X")
  flags+=("--cookie")
  flags+=("-b")
  multi_flags+=("--cookie")
  multi_flags+=("-b")
  flags+=("--header")
  flags+=("-H")
  multi_flags+=("--header")
  multi_flags+=("-H")
  flags+=("--watch")
  flags+=("-w")
  multi_flags+=("--watch")
  multi_flags+=("-w")
  flags+=("--debug")
}

_netlify_env()
{
  last_command=netlify_env
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_env__get()
{
  last_command=netlify_env__get
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_env__import()
{
  last_command=netlify_env__import
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--replaceExisting")
  flags+=("-r")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_env__list()
{
  last_command=netlify_env__list
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_env__set()
{
  last_command=netlify_env__set
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_env__unset()
{
  last_command=netlify_env__unset
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_functions()
{
  last_command=netlify_functions
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
}

_netlify_functions__build()
{
  last_command=netlify_functions__build
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--functions")
  flags+=("-f")
  multi_flags+=("--functions")
  multi_flags+=("-f")
  flags+=("--src")
  flags+=("-s")
  multi_flags+=("--src")
  multi_flags+=("-s")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_functions__create()
{
  last_command=netlify_functions__create
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--name")
  flags+=("-n")
  multi_flags+=("--name")
  multi_flags+=("-n")
  flags+=("--url")
  flags+=("-u")
  multi_flags+=("--url")
  multi_flags+=("-u")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_functions__invoke()
{
  last_command=netlify_functions__invoke
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--name")
  flags+=("-n")
  multi_flags+=("--name")
  multi_flags+=("-n")
  flags+=("--functions")
  flags+=("-f")
  multi_flags+=("--functions")
  multi_flags+=("-f")
  flags+=("--querystring")
  flags+=("-q")
  multi_flags+=("--querystring")
  multi_flags+=("-q")
  flags+=("--payload")
  flags+=("-p")
  multi_flags+=("--payload")
  multi_flags+=("-p")
  flags+=("--identity")
  flags+=("--port")
  multi_flags+=("--port")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_functions__list()
{
  last_command=netlify_functions__list
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--name")
  flags+=("-n")
  multi_flags+=("--name")
  multi_flags+=("-n")
  flags+=("--functions")
  flags+=("-f")
  multi_flags+=("--functions")
  multi_flags+=("-f")
  flags+=("--json")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_functions__serve()
{
  last_command=netlify_functions__serve
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--functions")
  flags+=("-f")
  multi_flags+=("--functions")
  multi_flags+=("-f")
  flags+=("--port")
  flags+=("-p")
  multi_flags+=("--port")
  multi_flags+=("-p")
  flags+=("--offline")
  flags+=("-o")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_init()
{
  last_command=netlify_init
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--manual")
  flags+=("-m")
  flags+=("--force")
  flags+=("--gitRemoteName")
  multi_flags+=("--gitRemoteName")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_link()
{
  last_command=netlify_link
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--id")
  multi_flags+=("--id")
  flags+=("--name")
  multi_flags+=("--name")
  flags+=("--gitRemoteName")
  multi_flags+=("--gitRemoteName")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_lm()
{
  last_command=netlify_lm
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_lm__info()
{
  last_command=netlify_lm__info
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_lm__install()
{
  last_command=netlify_lm__install
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--force")
  flags+=("-f")
}

_netlify_lm__setup()
{
  last_command=netlify_lm__setup
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--skip-install")
  flags+=("-s")
  flags+=("--force-install")
  flags+=("-f")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_lm__uninstall()
{
  last_command=netlify_lm__uninstall
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_login()
{
  last_command=netlify_login
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--new")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_logout()
{
  last_command=netlify_logout
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_open()
{
  last_command=netlify_open
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
  flags+=("--site")
  flags+=("--admin")
}

_netlify_open__admin()
{
  last_command=netlify_open__admin
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_open__site()
{
  last_command=netlify_open__site
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_sites()
{
  last_command=netlify_sites
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
}

_netlify_sites__config()
{
  last_command=netlify_sites__config
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--name")
  flags+=("-n")
  multi_flags+=("--name")
  multi_flags+=("-n")
}

_netlify_sites__create()
{
  last_command=netlify_sites__create
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--name")
  flags+=("-n")
  multi_flags+=("--name")
  multi_flags+=("-n")
  flags+=("--account-slug")
  flags+=("-a")
  multi_flags+=("--account-slug")
  multi_flags+=("-a")
  flags+=("--with-ci")
  flags+=("-c")
  flags+=("--manual")
  flags+=("-m")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_sites__delete()
{
  last_command=netlify_sites__delete
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--force")
  flags+=("-f")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_sites__list()
{
  last_command=netlify_sites__list
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--json")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_status()
{
  last_command=netlify_status
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--verbose")
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_status__hooks()
{
  last_command=netlify_status__hooks
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_switch()
{
  last_command=netlify_switch
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_unlink()
{
  last_command=netlify_unlink
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_watch()
{
  last_command=netlify_watch
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--debug")
  flags+=("--httpProxy")
  multi_flags+=("--httpProxy")
  flags+=("--httpProxyCertificateFilename")
  multi_flags+=("--httpProxyCertificateFilename")
}

_netlify_plugins()
{
  last_command=netlify_plugins
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--core")
}

_netlify_plugins__inspect()
{
  last_command=netlify_plugins__inspect
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--help")
  flags+=("-h")
  flags+=("--verbose")
  flags+=("-v")
}

_netlify_plugins__install()
{
  last_command=netlify_plugins__install
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--help")
  flags+=("-h")
  flags+=("--verbose")
  flags+=("-v")
  flags+=("--force")
  flags+=("-f")
}

_netlify_plugins__link()
{
  last_command=netlify_plugins__link
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--help")
  flags+=("-h")
  flags+=("--verbose")
  flags+=("-v")
}

_netlify_plugins__uninstall()
{
  last_command=netlify_plugins__uninstall
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--help")
  flags+=("-h")
  flags+=("--verbose")
  flags+=("-v")
}

_netlify_plugins__update()
{
  last_command=netlify_plugins__update
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--help")
  flags+=("-h")
  flags+=("--verbose")
  flags+=("-v")
}

_netlify_help()
{
  last_command=netlify_help
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--all")
}

_netlify_completion___flag_options--shell()
{
  local options=()
  options+=("bash")
  options+=("fish")
  options+=("zsh")
  COMPREPLY=( $( compgen -W "${options[*]}" -- "$cur" ) )
}
_netlify_completion()
{
  last_command=netlify_completion
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--shell")
  flags+=("-s")
  multi_flags+=("--shell")
  multi_flags+=("-s")
  option_flags+=("--shell")
  option_flag_handlers+=("_netlify_completion___flag_options--shell")
  option_flags+=("-s")
  option_flag_handlers+=("_netlify_completion___flag_options--shell")
  required_flags+=("--shell")
  required_flags+=("-s")
}

_netlify_completion__generate___flag_options--shell()
{
  local options=()
  options+=("bash")
  options+=("fish")
  options+=("zsh")
  COMPREPLY=( $( compgen -W "${options[*]}" -- "$cur" ) )
}
_netlify_completion__generate()
{
  last_command=netlify_completion__generate
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--shell")
  flags+=("-s")
  multi_flags+=("--shell")
  multi_flags+=("-s")
  option_flags+=("--shell")
  option_flag_handlers+=("_netlify_completion__generate___flag_options--shell")
  option_flags+=("-s")
  option_flag_handlers+=("_netlify_completion__generate___flag_options--shell")
  required_flags+=("--shell")
  required_flags+=("-s")
}

_netlify_completion__generate__alias___flag_options--shell()
{
  local options=()
  options+=("bash")
  options+=("fish")
  COMPREPLY=( $( compgen -W "${options[*]}" -- "$cur" ) )
}
_netlify_completion__generate__alias()
{
  last_command=netlify_completion__generate__alias
  commands=()
  command_aliases=()
  args=()
  flags=()
  flag_aliases=()
  multi_flags=()
  option_flags=()
  option_flag_handlers=()
  required_flags=()
  inserted_flags=()
  flags+=("--shell")
  flags+=("-s")
  multi_flags+=("--shell")
  multi_flags+=("-s")
  option_flags+=("--shell")
  option_flag_handlers+=("_netlify_completion__generate__alias___flag_options--shell")
  option_flags+=("-s")
  option_flag_handlers+=("_netlify_completion__generate__alias___flag_options--shell")
  required_flags+=("--shell")
  required_flags+=("-s")
}

_netlify()
{
  commands=()
  commands+=("addons")
  command_aliases+=("addon")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[addon]=addons
  else
    command+=("addon")
  fi
  commands+=("addons:auth")
  command_aliases+=("addon:auth")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[addon:auth]=addons:auth
  else
    command+=("addon:auth")
  fi
  commands+=("addons:config")
  command_aliases+=("addon:config")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[addon:config]=addons:config
  else
    command+=("addon:config")
  fi
  commands+=("addons:create")
  command_aliases+=("addon:create")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[addon:create]=addons:create
  else
    command+=("addon:create")
  fi
  commands+=("addons:delete")
  command_aliases+=("addon:delete")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[addon:delete]=addons:delete
  else
    command+=("addon:delete")
  fi
  commands+=("addons:list")
  command_aliases+=("addon:list")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[addon:list]=addons:list
  else
    command+=("addon:list")
  fi
  commands+=("api")
  commands+=("build")
  commands+=("deploy")
  commands+=("dev")
  commands+=("dev:exec")
  commands+=("dev:trace")
  commands+=("env")
  commands+=("env:get")
  commands+=("env:import")
  commands+=("env:list")
  commands+=("env:set")
  commands+=("env:unset")
  command_aliases+=("env:delete")
  command_aliases+=("env:remove")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[env:delete]=env:unset
    command_by_alias[env:remove]=env:unset
  else
    command+=("env:delete")
    command+=("env:remove")
  fi
  commands+=("functions")
  command_aliases+=("function")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[function]=functions
  else
    command+=("function")
  fi
  commands+=("functions:build")
  command_aliases+=("function:build")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[function:build]=functions:build
  else
    command+=("function:build")
  fi
  commands+=("functions:create")
  command_aliases+=("function:create")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[function:create]=functions:create
  else
    command+=("function:create")
  fi
  commands+=("functions:invoke")
  command_aliases+=("function:trigger")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[function:trigger]=functions:invoke
  else
    command+=("function:trigger")
  fi
  commands+=("functions:list")
  command_aliases+=("function:list")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[function:list]=functions:list
  else
    command+=("function:list")
  fi
  commands+=("functions:serve")
  command_aliases+=("function:serve")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[function:serve]=functions:serve
  else
    command+=("function:serve")
  fi
  commands+=("init")
  commands+=("link")
  commands+=("lm")
  commands+=("lm:info")
  commands+=("lm:install")
  command_aliases+=("lm:init")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[lm:init]=lm:install
  else
    command+=("lm:init")
  fi
  commands+=("lm:setup")
  commands+=("login")
  commands+=("open")
  commands+=("open:admin")
  commands+=("open:site")
  commands+=("sites")
  commands+=("sites:create")
  commands+=("sites:delete")
  commands+=("sites:list")
  commands+=("status")
  commands+=("status:hooks")
  commands+=("switch")
  commands+=("unlink")
  commands+=("watch")
  commands+=("plugins")
  commands+=("plugins:inspect")
  commands+=("plugins:install")
  command_aliases+=("plugins:add")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[plugins:add]=plugins:install
  else
    command+=("plugins:add")
  fi
  commands+=("plugins:link")
  commands+=("plugins:uninstall")
  command_aliases+=("plugins:unlink")
  command_aliases+=("plugins:remove")
  if [[ -z "${BASH_VERSION}" || "${BASH_VERSINFO[0]}" -gt 3 ]]; then
    command_by_alias[plugins:unlink]=plugins:uninstall
    command_by_alias[plugins:remove]=plugins:uninstall
  else
    command+=("plugins:unlink")
    command+=("plugins:remove")
  fi
  commands+=("plugins:update")
  commands+=("help")
  commands+=("completion")
  commands+=("completion:generate")
  commands+=("completion:generate:alias")
  last_command=netlify
}

__netlify_init()
{
  __netlify_debug ""

  local cur prev words cword

  if declare -F _init_completion >/dev/null 2>&1; then
    _init_completion -n ":" -n "=" || return
  else
    __netlify_init_completion -n ":" -n "="  || return
  fi

  __netlify_debug "${FUNCNAME[0]}: words is ${words[@]}"

  local c=0
  local last_command

  local commands=("netlify")
  local command_aliases=()
  declare -A command_by_alias 2>/dev/null || :

  local args=()

  local flags=()

  local multi_flags=()
  local option_flags=()
  local option_flag_handlers=()

  local inserted_flags=()

  __netlify_handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
  complete -o default -F __netlify_init netlify
  complete -o default -F __netlify_init ntl
else
  complete -o default -o nospace -F __netlify_init netlify
  complete -o default -o nospace -F __netlify_init ntl
fi
