#!/bin/bash
#
# Takes a newly generated fail_expectations and attempts to merge/commit it into
# the repository
set -euv

new_expectations="$1"
file="$2"
buildername="$3"
buildnumber="$4"
changeset="$5"

# check if push is necessary
if diff "${new_expectations}" "${file}" >& /dev/null; then
	echo "No differences"
	exit 0
fi

# ensure 'origin' remote is set
git remote rm origin || true
git remote add origin /ben/local/GIT/public/firm-testresults

# construct commit message
TCM="tmp_commit_message.txt"
echo "buildbot update ${buildername} ${buildnumber}" >${TCM}
echo "" >>${TCM}
echo "Revisions used:" >>${TCM}
echo "$changeset" | sed -e "s/;/\n/g" -e "s/=/ = /g" >>${TCM}
echo "" >>${TCM}
echo "See: http://buildbot.info.uni-karlsruhe.de/builders/${buildername// /%20}/builds/${buildnumber}" >>${TCM}

# locally commit changes
cp "${new_expectations}" "${file}"
git add "${file}"
git config user.email "firm@ipd.info.uni-karlsruhe.de"
git config user.name "buildbot"
git commit --file=${TCM}
rm ${TCM}

# publish changes
while ! git push origin master -u; do
	echo "Out-of-date: " $(git describe --always --tags)
	git fetch origin
	git rebase origin/master -s recursive -X theirs
	echo "Updated to: " $(git describe --always --tags)
done
