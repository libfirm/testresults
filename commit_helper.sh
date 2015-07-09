#!/bin/bash
#
# Takes a newly generated fail_expectations and attempts to merge/commit it into
# the repository
set -euv

new_expectations="$1"
file="$2"
buildername="$3"
buildnumber="$4"

# check if push is necessary
if diff "${new_expectations}" "${file}" >& /dev/null; then
	echo "No differences"
	exit 0
fi

# ensure 'origin' remote is set
git remote rm origin || true
git remote add origin /ben/local/GIT/public/firm-testresults

# locally commit changes
cp "${new_expectations}" "${file}"
git add "${file}"
git config user.email "firm@ipd.info.uni-karlsruhe.de"
git config user.name "buildbot"
git commit -m "buildbot update ${buildername} ${buildnumber}"

# publish changes
while ! git push origin master -u; do
	echo "Out-of-date: " $(git describe --always --tags)
	git fetch origin
	git rebase origin/master -s recursive -X theirs
	echo "Updated to: " $(git describe --always --tags)
done
