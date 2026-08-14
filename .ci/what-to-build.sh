#!/usr/bin/env bash

function custom-kernel() {
	[[ -n "$CUSTOM_KERNEL" ]] &&
		echo " $CUSTOM_KERNEL" >>/tmp/TO_BUILD &&
		echo "Using $CUSTOM_KERNEL as kernel." &&
		exit 0

	[[ "$CI_COMMIT_MESSAGE" == *"["*"-k"*"]"* ]] &&
		CUSTOM_KERNEL=$(echo "$CI_COMMIT_MESSAGE" | grep -Po "(?<=\[).*(?=\])" | awk -F ' ' '{ print $4 }') &&
		echo " $CUSTOM_KERNEL" >>/tmp/TO_BUILD &&
		echo "Using $CUSTOM_KERNEL as kernel." &&
		exit 0

	# if no custom kernel is specified, we still want to exit gracefully
	exit 0
}

function trigger-build() {
	read -r ISO_FLAVOUR KERNEL_FLAVOUR </tmp/TO_BUILD

	if [[ "$ISO_FLAVOUR" == "buildall" ]]; then
		CMD="ci-trigger buildall"
	elif [[ -n "$KERNEL_FLAVOUR" ]]; then
		CMD="ci-trigger $ISO_FLAVOUR $KERNEL_FLAVOUR"
	else
		CMD="ci-trigger $ISO_FLAVOUR"
	fi

	echo "Triggering build server: $CMD"
	ssh -p "${BUILD_PORT:-220}" -o StrictHostKeyChecking=no "${BUILD_USER:-gitlab}"@"${BUILD_HOST:-builds.garudalinux.org}" "$CMD"
	exit 0
}

# Read a list of flavours from the community and garuda directories
mapfile -t _FLAVOUR < <(find {community,garuda} -mindepth 1 -type d -prune | sed -e 's/community\///' -e 's/garuda\///')

# Check whether a manual build has been requested via GitLab web ui
if [[ -n "$MANUAL_BUILD" ]]; then
	[[ "$MANUAL_BUILD" == "all" ]] &&
		echo "buildall" >>/tmp/TO_BUILD &&
		echo "Requested a buildall run." &&
		custom-kernel &&
		trigger-build

	for i in "${_FLAVOUR[@]}"; do
		# shellcheck disable=SC2076
		[[ "$MANUAL_BUILD" == "$i" ]] &&
			echo "$i" >>/tmp/TO_BUILD &&
			echo "Requested ISO build for $i." &&
			custom-kernel &&
			trigger-build
	done

else
	# Only check for commit messages if no manual build has been requested
	[[ "$CI_COMMIT_MESSAGE" == *"[build all]"* ]] &&
		echo "buildall" >>/tmp/TO_BUILD &&
		echo "Requested a buildall run." &&
		custom-kernel &&
		trigger-build

	for i in "${_FLAVOUR[@]}"; do
		# shellcheck disable=SC2076
		[[ "$CI_COMMIT_MESSAGE" == *"[build $i]"* ]] &&
			echo "$i" >>/tmp/TO_BUILD &&
			echo "Requested ISO build for $i." &&
			custom-kernel &&
			trigger-build
	done
fi
echo "No valid flavour to build found in commit message, aborting." && exit 1
