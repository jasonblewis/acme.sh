#!/usr/bin/env sh
# shellcheck disable=SC2034

dns_rimuhosting_info='rimuhosting.com
Site: rimuhosting.com
Docs: github.com/acmesh-official/acme.sh/wiki/dnsapi
Options:
 RH_Key API Key
'

: "${LE_WORKING_DIR:=$HOME/.acme.sh}"

# Provider parameters
RZ_PROVIDER="rimuhosting"
RZ_KEY_VAR="RH_Key"
RZ_API="https://rimuhosting.com/dns/dyndns.jsp"

# source the rimuhosting and zonomi common lib
_common="${_SCRIPT_HOME%/}/dnsapi/lib/dns_rz_common.sh"
[ -r "$_common" ] || { _err "Missing helper: $_common"; return 1; }
# shellcheck source=lib/dns_rz_common.sh
. "$_common"



# Exported entrypoints for acme.sh
dns_rimuhosting_add() { rz_add "$@"; }
dns_rimuhosting_rm()  { rz_rm  "$@"; }
