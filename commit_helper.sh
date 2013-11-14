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

git remote add origin /ben/local/GIT/public/firm-testresults

cp "${new_expectations}" "${file}"
git add "${file}"
git commit -m "buildbot update" --author "buildbot <firm@ipd.info.uni-karlsruhe.de>"
while ! git push origin master -u; do
	git fetch origin
	git rebase master -s theirs
done
