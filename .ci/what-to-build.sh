#!/usr/bin/env bash
mapfile -t _FLAVOUR < <(find {community,garuda} -mindepth 1 -type d -prune | sed -e 's/community\///' -e 's/garuda\///')

# Check whether a manual build has been requested via GitLab web ui
if [[ -n "$MANUAL_BUILD" ]]; then
	[[ "$MANUAL_BUILD" == "all" ]] &&
		echo "buildall" >>/tmp/TO_BUILD &&
		echo "Requested a buildall run." &&
		exit 0

	for i in "${_FLAVOUR[@]}"; do
		# shellcheck disable=SC2076
		[[ "$MANUAL_BUILD" == *"[build $i]"* ]] &&
			echo "$i" >>/tmp/TO_BUILD &&
			echo "Requested ISO build for $i." &&
			exit 0
	done
else
	# Only check for commit messages if no manual build has been requested
	[[ "$CI_COMMIT_MESSAGE" == *"[build all]"* ]] &&
		echo "buildall" >>/tmp/TO_BUILD &&
		echo "Requested a buildall run." &&
		exit 0

	for i in "${_FLAVOUR[@]}"; do
		# shellcheck disable=SC2076
		[[ "$CI_COMMIT_MESSAGE" == *"[build $i]"* ]] &&
			echo "$i" >>/tmp/TO_BUILD &&
			echo "Requested ISO build for $i." &&
			exit 0
	done
fi
echo "No valid flavour to build found in commit message, aborting." && exit 1
