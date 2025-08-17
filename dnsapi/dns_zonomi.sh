#!/usr/bin/env sh
# shellcheck disable=SC2034

dns_zonomi_info='zonomi.com
Site: zonomi.com
Docs: github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_zonomi
Options:
 ZM_Key API Key
'

: "${LE_WORKING_DIR:=$HOME/.acme.sh}"

RZ_PROVIDER="zonomi"
RZ_KEY_VAR="ZM_Key"
RZ_API="https://zonomi.com/app/dns/dyndns.jsp"

# source the rimuhosting and zonomi common lib
_common="${_SCRIPT_HOME%/}/dnsapi/lib/dns_rz_common.sh"
[ -r "$_common" ] || { _err "Missing helper: $_common"; return 1; }
. "$_common"

dns_zonomi_add() { rz_add "$@"; }
dns_zonomi_rm()  { rz_rm  "$@"; }
