watch () {
	PState=$1
	PDef=$2
	SP=$3
    SO=$(cat $PState)
    SN=$(callOne $PDef/watch $SO "xxx" \
	"./$SO
         ./default
         /bin/false" \
		 "$SP") \
		 || fail "Watch script failed or missing"
    [ -n "$SN" ] || fail "Watch script $S0 returned empty state name"
    change $PState $PDef $SN $SP
}

change () {
	PState=$1
	PDef=$2
    SO=$(cat $PState)
    SN=$3
	SP=$4
    if [ "$SO" != "$SN" ]; then
	if [ -x $PDef/trans/$SO-$SN.trans ]; then
	    # one script to handle whole transition
	    callOne $PDef/trans $SO $SN \
		"./$SO-$SN.trans" \
		"$SP" \
		|| fail "State transition script failed"
	else
	    # seperate scripts for leaving and entering states
	    callOne $PDef/trans $SO $SN \
		"./$SO.leave
                 ./default.leave
                 /bin/true" \
		"$SP" \
		|| fail "State leave script failed"
	    callOne $PDef/trans $SO $SN \
		"./$SN.enter
                 ./default.enter
                 /bin/true" \
		"$SP" \
		|| fail "State enter script failed"

	fi
	echo $SN > $PState
    fi
}

callOne () { # args: cwd arg1 arg2 cmdlist cmdpmeter
    echo "$4" | sed 's/ *//' | (
	set -e
	cd $1
	while read cmd; do
	    if [ -x "$cmd" ]; then
		$cmd $2 $3 $(echo "$5" | sed 's/ *//') 666<&-
		exit $?
	    fi
	done )
}

lockState () {
    # lock state file (neccessary also for watch, as it calls scripts
    # that assume a certain state as active during their whole
    # execution time)
    exec 666<$1
    flock -x 666
}

fail() {
    echo "[FAILURE]: $1" 1>&2
    exit 1
}