declare -g -A __dplg_v_plugins

deplug() {
  local -A __dplg_v_colo=()
  local \
    __dplg_v_errcode=0 \
    __dplg_v_verbose=0 \
    __dplg_v_yes=0 \
    __dplg_v_usecolo=1
    __dplg_v_errmsg= \
    __dplg_v_key= \
    __dplg_v_pwd= \
    __dplg_v_cmd= \
    __dplg_v_plugin= \
    __dplg_v_as= \
    __dplg_v_dir= \
    __dplg_v_of= \
    __dplg_v_use= \
    __dplg_v_tag= \
    __dplg_v_post= \
    __dplg_v_from='https://github.com' \
    __dplg_v_status= \
    __dplg_v_home=${DEPLUG_HOME:-~/.deplug} \
    __dplg_v_state= \
    __dplg_v_repo= \
    __dplg_v_bin= \
    __dplg_v_cache=

  __dplg_v_repo=${DEPLUG_REPO:-${__dplg_v_home}/repos}
  __dplg_v_state=${DEPLUG_STATE:-${__dplg_v_home}/state}
  __dplg_v_bin=${DEPLUG_BIN:-${__dplg_v_home}/bin}
  __dplg_v_cache=${DEPLUG_CACHE:-${__dplg_v_home}/cache}

  __dplg_f_parseArgs "$@"

  if [[ -z ${__dplg_v_cmd} ]]
  then
    __dplg_c_help
    return 1
  fi

  __dplg_f_verbose "Call command ${__dplg_v_cmd}"
  "__dplg_c_${__dplg_v_cmd}"
}

__dplg_c_reset() {
  unset __dplg_v_plugins
  declare -g -A __dplg_v_plugins=()
}

__dplg_c_include() {
  [[ -f ${__dplg_v_cache} ]] || __dplg_c_reload
  source "${__dplg_v_cache}"
}

__dplg_c_check() {
  __dplg_f_init

  while read plug
  do
    __dplg_f_parse "${plug}"
    [[ ! -z "${__dplg_v_plugins[${__dplg_v_as}]}" ]] || return 1
  done < ${__dplg_v_state}
}

__dplg_c_reload() {
  [[ ! -z ${__dplg_v_plugins[@]} ]] || return

  __dplg_f_init

  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    __dplg_f_of
    __dplg_f_use
  done
}

__dplg_c_install() {
  [[ ! -z ${__dplg_v_plugins[@]} ]] || return

  __dplg_f_init
  __dplg_f_check_plugins < ${__dplg_v_state}
  __dplg_f_plugins | __dplg_f_install > ${__dplg_v_state}
  __dplg_f_defrost < ${__dplg_v_state}

  __dplg_f_plugins | __dplg_f_save_cache > ${__dplg_v_cache}
  __dplg_f_load_cache "${__dplg_v_cache}"
}

__dplg_c_upgrade() {
  [[ ! -z ${__dplg_v_plugins[@]} ]] || return

  __dplg_f_init
  __dplg_f_check_plugins < ${__dplg_v_state}
  __dplg_f_plugins | __dplg_f_upgrade > ${__dplg_v_state}
  __dplg_f_defrost < ${__dplg_v_state}

  __dplg_f_plugins | __dplg_f_save_cache > ${__dplg_v_cache}
  __dplg_f_load_cache "${__dplg_v_cache}"
}

__dplg_f_load_cache() {
  source $1
}

__dplg_f_save_cache() {
  echo "export PATH=\"\${PATH}:${__dplg_v_bin}\""

  while read plug
  do
    __dplg_f_parse "${plug}"
    [[ 0 -eq ${__dplg_v_status} ]] || continue

    {
      __dplg_f_of
      __dplg_f_use
    } &
  done | cat
}

__dplg_f_message() {
  if [[ -z $@ ]]
  then
    while read msg
    do echo -e ${msg} >&2
    done
  else
    echo -e "$@" >&2
  fi
}

__dplg_f_check_plugins() {
  while read plug
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stringify | sed -e 's/^/[DEBUG] check previous /g' | __dplg_f_verbose

    [[ ! -z ${__dplg_v_as} ]] || continue

    if [[ -z ${__dplg_v_plugins[${__dplg_v_as}]} ]]
    then
      __dplg_f_append 3
      continue
    fi

    local curr_status=${__dplg_v_plugins[${__dplg_v_as}]##*status:}

    if [[ 0 -gt ${curr_status} ]]
    then continue
    fi

    if [[ ${plug} != ${__dplg_v_plugins[${__dplg_v_as}]} ]]
    then
      __dplg_f_parse "${__dplg_v_plugins[${__dplg_v_as}]}"
      __dplg_f_append 2
    fi
  done
}

__dplg_f_defrost() {
  while read plug
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stringify | sed -e 's/^/[DEBUG] defrost /g' | __dplg_f_verbose

    [[ ! -z ${__dplg_v_as} ]] || continue

    __dplg_f_append
  done
}

__dplg_f_freeze() {
  while read plug
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stringify | sed -e 's/^/[DEBUG] freeze /g' | __dplg_f_verbose

    [[ ! -z ${__dplg_v_as} ]] || continue

    __dplg_f_stringify
  done
}

__dplg_f_plugins() {
  for plug in "${__dplg_v_plugins[@]}"
  do echo ${plug}
  done
}

__dplg_f_install() {
  local __dplg_v_errmsg= __dplg_v_errcode=0
  while read plug
  do
    __dplg_f_parse "${plug}"

    __dplg_f_stringify | sed -e 's/^/[DEBUG] install /g' | __dplg_f_verbose

    case ${__dplg_v_status} in
      0|3)
        __dplg_f_stringify ${__dplg_v_status}
        continue
        ;;
    esac

    {
      __dplg_f_message "${__dplg_v_colo[blu]}Install..${__dplg_v_colo[res]} ${__dplg_v_as}"

      __dplg_v_errmsg=$(__dplg_f_download 2>&1)
      [[ 0 -eq $? ]] || __dplg_v_errcode=1

      if [[ 0 -eq ${__dplg_v_errcode} ]]
      then
        __dplg_v_errmsg=$(__dplg_f_post 2>&1)
        [[ 0 -eq $? ]] || __dplg_v_errcode=1
      fi

      if [[ 0 -eq ${__dplg_v_errcode} ]]
      then
        __dplg_f_message "${__dplg_v_colo[cya]}Installed${__dplg_v_colo[res]} ${__dplg_v_as} ${__dplg_v_colo[cya]}${__dplg_v_errmsg[@]}${__dplg_v_colo[res]}"
        __dplg_f_stringify 0
      else
        __dplg_f_message "${__dplg_v_colo[red]}Failed   ${__dplg_v_colo[res]} ${__dplg_v_as} ${__dplg_v_colo[red]}${__dplg_v_errmsg[@]}${__dplg_v_colo[res]}"
        __dplg_f_stringify 4
      fi

    } &
  done | cat
}

__dplg_f_upgrade() {
  local __dplg_v_errmsg= __dplg_v_errcode=0
  while read plug
  do
    __dplg_f_parse "${plug}"

    case ${__dplg_v_status} in
      3)
        __dplg_f_stringify ${__dplg_v_status}
        continue
        ;;
    esac

    {
      __dplg_f_message "${__dplg_v_colo[blu]}Update.. ${__dplg_v_colo[res]} ${__dplg_v_as}"

      __dplg_v_errmsg=$(__dplg_f_update 2>&1)
      [[ 0 -eq $? ]] || __dplg_v_errcode=1

      if [[ 0 -eq ${__dplg_v_errcode} ]]
      then
        __dplg_v_errmsg=$(__dplg_f_post 2>&1)
        [[ 0 -eq $? ]] || __dplg_v_errcode=1
      fi

      if [[ 0 -eq ${__dplg_v_errcode} ]]
      then
        __dplg_f_message "${__dplg_v_colo[cya]}Updated  ${__dplg_v_colo[res]} ${__dplg_v_as} ${__dplg_v_colo[cya]}${__dplg_v_errmsg[@]}${__dplg_v_colo[res]}"
        __dplg_f_stringify 0
      else
        __dplg_f_message "${__dplg_v_colo[red]}Failed   ${__dplg_v_colo[res]} ${__dplg_v_as} ${__dplg_v_colo[red]}${__dplg_v_errmsg[@]}${__dplg_v_colo[res]}"
        __dplg_f_stringify 4
      fi

    } &
  done | cat
}

__dplg_f_stringify() {
  [[ ! -z ${__dplg_v_as} ]] || return

  echo "as:${__dplg_v_as}#plugin:${__dplg_v_plugin}#dir:${__dplg_v_dir}#tag:${__dplg_v_tag}#of:${__dplg_v_of}#use:${__dplg_v_use}#post:${__dplg_v_post}#from:${__dplg_v_from}#status:${1:-${__dplg_v_status}}"
}

__dplg_c_clean() {
  local -a __dplg_v_trash=()
  local __dplug_v_ans=

  __dplg_f_init
  __dplg_f_check_plugins < ${__dplg_v_state}

  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"
    __dplg_f_stringify | sed -e 's/^/[DEBUG] clean /g' | __dplg_f_verbose

    if [[ 0 -eq ${__dplg_v_verbose} ]]
    then __dplg_v_display="${__dplg_v_as}"
    else __dplg_v_display="${__dplg_v_as} (plugin: ${__dplg_v_plugin}, dir: ${__dplg_v_dir})"
    fi

    case ${__dplg_v_status} in
      3|4)
        echo ${__dplg_v_status} | sed -e 's/^/[DEBUG] clean status /g' | __dplg_f_verbose
        __dplg_f_message "${__dplg_v_colo[yel]}Cached   ${__dplg_v_colo[res]} ${__dplg_v_display}"
        __dplg_v_trash=("${__dplg_v_trash[@]}" "${__dplg_v_as}")
        ;;
    esac
  done

  [[ -z "${__dplg_v_trash[@]}" ]] && return

  if [[ 0 -eq ${__dplg_v_yes} ]]
  then
    echo -n -e "${__dplg_v_colo[yel]}Do you really want to clean? [y/N]: ${__dplg_v_colo[res]}"
    read __dplug_v_ans
    echo
  else
    __dplug_v_ans=y
  fi

  if [[ "${__dplug_v_ans}" =~ y ]]
  then
    for __dplg_v_as in "${__dplg_v_trash[@]}"
    do
      __dplg_f_parse "${__dplg_v_plugins[${__dplg_v_as}]}"

      if [[ 0 -eq ${__dplg_v_verbose} ]]
      then __dplg_v_display="${__dplg_v_as}"
      else __dplg_v_display="${__dplg_v_as} (plugin: ${__dplg_v_plugin}, dir: ${__dplg_v_dir})"
      fi

      if [[ ! -z ${__dplg_v_dir} ]]
      then
        __dplg_f_message "${__dplg_v_colo[mag]}Clean..  ${__dplg_v_colo[res]} ${__dplg_v_display}"
        rm -rf "${__dplg_v_dir}"
        unset "__dplg_v_plugins[${__dplg_v_as}]"
        __dplg_f_message "${__dplg_v_colo[red]}Cleaned  ${__dplg_v_colo[res]} ${__dplg_v_display}"
      fi
    done
  fi

  __dplg_f_plugins | __dplg_f_freeze > ${__dplg_v_state}
}

__dplg_c_status() {
  local __dplg_v_display=
  local __dplg_v_iserr=0

  if [[ 0 -gt ${__dplg_v_verbose} ]]
  then __dplg_f_check_plugins < ${__dplg_v_state}
  fi

  for plug in "${__dplg_v_plugins[@]}"
  do
    __dplg_f_parse "${plug}"

    if [[ 0 -eq ${__dplg_v_verbose} ]]
    then __dplg_v_display="${__dplg_v_as}"
    else __dplg_v_display="${__dplg_v_as} (plugin: ${__dplg_v_plugin}, dir: ${__dplg_v_dir})"
    fi

    case ${__dplg_v_status} in
      0)
        __dplg_f_message "${__dplg_v_colo[cya]}Installed${__dplg_v_colo[res]} ${__dplg_v_display}"
        ;;
      1)
        __dplg_f_message "${__dplg_v_colo[mag]}NoInstall${__dplg_v_colo[res]} ${__dplg_v_display}"
        __dplg_v_iserr=1
        ;;
      2)
        __dplg_f_message "${__dplg_v_colo[blu]}Changed  ${__dplg_v_colo[res]} ${__dplg_v_display}"
        __dplg_v_iserr=1
        ;;
      3)
        __dplg_f_message "${__dplg_v_colo[yel]}Cached   ${__dplg_v_colo[res]} ${__dplg_v_display}"
        __dplg_v_iserr=1
        ;;
      4)
        __dplg_f_message "${__dplg_v_colo[red]}Failed   ${__dplg_v_colo[res]} ${__dplg_v_display}"
        __dplg_v_iserr=1
        ;;
    esac
  done

  return ${__dplg_v_iserr}
}

__dplg_c_append() {
  local plug=$(__dplg_f_stringify)

  if [[ ! -d ${__dplg_v_dir} ]]
  then __dplg_f_append 1
  elif [[ -z ${__dplg_v_plugins[${__dplg_v_as}]} ]]
  then __dplg_f_append 0
  elif [[ "${__dplg_v_plugins[${__dplg_v_as}]}" == "${plug}" ]]
  then __dplg_f_append 0
  else __dplg_f_append 2
  fi
}

__dplg_f_append() {
  # status 0 ... already installed
  # status 1 ... not install
  # status 2 ... changed
  # status 3 ... cached
  # status 4 ... error

  [[ ! -z ${__dplg_v_as} ]] || return

  __dplg_v_plugins[${__dplg_v_as}]="as:${__dplg_v_as}#plugin:${__dplg_v_plugin}#dir:${__dplg_v_dir}#tag:${__dplg_v_tag}#of:${__dplg_v_of}#use:${__dplg_v_use}#post:${__dplg_v_post}#from:${__dplg_v_from}#status:${1:-${__dplg_v_status}}"
}

__dplg_f_remove() {
  unset "__dplg_v_plugins[${__dplg_v_as}]"
}

__dplg_c_help() {
  echo
}
