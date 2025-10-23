#! /bin/sh
# Copyright (C) 2024 Red Hat, Inc.
# This file is part of elfutils.
#
# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# elfutils is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

. $srcdir/test-subr.sh

# See run-stack-d-test.sh for dwarfinlines.cpp source.
testfiles testfiledwarfinlines testfiledwarfinlines.core

# Depending on whether we are running make check or make installcheck
# the actual binary name under test might be different.
if test "$elfutils_testrun" = "installed"; then
STACKCMD=${bindir}/`program_transform stack`
else
STACKCMD=${abs_top_builddir}/src/stack
fi

# Disable valgrind while dumping because of a bug unmapping libc.so.
# https://bugs.kde.org/show_bug.cgi?id=327427
SAVED_VALGRIND_CMD="$VALGRIND_CMD"
unset VALGRIND_CMD

# Test the -g option to show signal information.
# Use --raw and limit frames to 2 to keep output deterministic, like other tests.
# Match approach used in run-stack-i-test.sh: run the binary via abs_top_builddir
# and expect the error prefix to contain $STACKCMD.
testrun_compare ${abs_top_builddir}/src/stack -g -r -n 2 -e testfiledwarfinlines --core testfiledwarfinlines.core <<EOF
Signal 8 (Floating point exception)
  si_code: 0
PID 13654 - core
TID 13654:
#0  0x00000000004006c8 _Z2fui
#1  0x00000000004004c5 main
$STACKCMD: tid 13654: shown max number of frames (2, use -n 0 for unlimited)
EOF

# Restore valgrind for other tests
export VALGRIND_CMD="$SAVED_VALGRIND_CMD"

exit 0
