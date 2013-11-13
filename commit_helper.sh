#!/bin/bash
#
# Takes a newly generated fail_expectations and attempts to merge/commit it into
# the repository
set -euv

new_expectations="$1"
file="$2"

if diff "${new_expectations}" "${file}" >& /dev/null; then
	echo "No differences"
	exit 0
fi

cp "${new_expectations}" "${file}"
git add "${file}"
git commit -m "buildbot update"
while ! git push origin master -u; do
	git pull --rebase -s ours
done
