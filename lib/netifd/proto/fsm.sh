#!/bin/sh
# FSM - Inetable Netifd backend
# Copyright (c) 2013 Cyrus 

[ -n "$INCLUDE_ONLY" ] || {
	. /lib/functions.sh
	. /lib/functions/network.sh
	. ../netifd-proto.sh
	init_proto "$@"
}

proto_fsm_init_config() {
	proto_config_add_string "dummy"
}

proto_fsm_setup() {
	local interface="$1"
	local config="$1"
	local iface="$2"

	proto_export "INTERFACE=$config"
	proto_run_command "$interface" start-stop-daemon -S -x \
		netifd-fsm \
		/var/run/netifd-$iface.pid \
		$iface \
		$interface
}

proto_fsm_teardown() {
	local interface="$1"
	proto_kill_command "$interface"
}

[ -n "$INCLUDE_ONLY" ] || {
	add_protocol fsm
}