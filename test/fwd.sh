#!/bin/sh
# Test FWD between two syslogd, second binds 127.0.0.2:4444
set -ex
if [ x"${srcdir}" = x ]; then
    srcdir=.
fi
. ${srcdir}/test.rc

export MSG="fwd and allow"

cat <<EOF >${CONFD}/fwd.conf
ntp.*	@127.0.0.2:${PORT2}	;RFC5424
EOF

cat <<EOF >${CONFD2}/50-default.conf
*.*	${LOG2}			;RFC5424
EOF

../src/syslogd -a 127.0.0.2:${PORT} -b :${PORT2} -d -F -f ${CONF2} -p ${SOCK2} &
echo "$!" > ${PID2}

kill -HUP `cat ${PID}`
sleep 2

# Enable debug for second syslogd
kill -USR1 `cat ${PID2}`

../src/logger -t fwd -p ntp.notice -u ${SOCK} -m "NTP123" ${MSG}
sleep 3
grep "fwd - NTP123 - ${MSG}" ${LOG2}
