#!/usr/bin/env sh
# shellcheck disable=SC2034

# Required provider vars to be set by caller:
#   RZ_PROVIDER   (e.g. "rimuhosting" or "zonomi" — for logs)
#   RZ_KEY_VAR    (e.g. "RH_Key" or "ZM_Key")
#   RZ_API        (e.g. "https://rimuhosting.com/dns/dyndns.jsp")

_rz_err()  { _err  "[$RZ_PROVIDER] $*"; }
_rz_info() { _info "[$RZ_PROVIDER] $*"; }
_rz_dbg()  { _debug "[$RZ_PROVIDER] $*"; }

# Indirect read of env var named in $RZ_KEY_VAR into RZ_KEY
_rz_read_key() {
  # Prefer env var (exported by user), else account conf
  # shellcheck disable=SC2016
  eval "RZ_KEY=\${$RZ_KEY_VAR}"
  if [ -z "$RZ_KEY" ]; then
    RZ_KEY="$(_readaccountconf_mutable "$RZ_KEY_VAR")"
  fi
  if [ -z "$RZ_KEY" ]; then
    _rz_err "No API key set. Export $RZ_KEY_VAR or save it via acme.sh env."
    return 1
  fi
  # Persist under the *provider-specific* key var
  _saveaccountconf_mutable "$RZ_KEY_VAR" "$RZ_KEY"
  return 0
}

# qstr: query string without api_key
_rz_request() {
  qstr=$1
  _rz_dbg "qstr: $qstr"
  _rz_url="$RZ_API?api_key=$RZ_KEY&$qstr"
  _rz_dbg "_url: $_rz_url"
  response="$(_get "$_rz_url")" || return 1
  _debug2 response "$response"
  _contains "$response" "<is_ok>OK:"
}

# Add or update a TXT record
# $1: fulldomain  $2: txtvalue
rz_add() {
  fulldomain=$1
  txtvalue=$2

  _rz_read_key || return 1

  _rz_info "Get existing txt records for $fulldomain"
  if ! _rz_request "action=QUERY&name=$fulldomain"; then
    _rz_err "QUERY failed"
    return 1
  fi

  if _contains "$response" "<record"; then
    _rz_dbg "update existing TXT set"
    _qstr="action[1]=SET&type[1]=TXT&name[1]=$fulldomain&value[1]=$txtvalue"
    _qindex=2
    for t in $(echo "$response" | tr -d "\r\n" | _egrep_o '<action.*</action>' \
                | tr "<" "\n" | grep record | grep 'type="TXT"' | cut -d '"' -f 6); do
      _debug2 t "$t"
      _qstr="$_qstr&action[$_qindex]=SET&type[$_qindex]=TXT&name[$_qindex]=$fulldomain&value[$_qindex]=$t"
      _qindex="$(_math "$_qindex" + 1)"
    done
    _rz_request "$_qstr"
  else
    _rz_dbg "add new TXT"
    _rz_request "action=SET&type=TXT&name=$fulldomain&value=$txtvalue"
  fi
}

# Remove TXT record(s)
# $1: fulldomain  $2: txtvalue (ignored; API deletes by name)
rz_rm() {
  fulldomain=$1
  # txtvalue=$2
  _rz_read_key || return 1
  _rz_request "action=DELETE&type=TXT&name=$fulldomain"
}
