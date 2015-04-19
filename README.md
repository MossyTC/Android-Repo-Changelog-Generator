# Android-Repo-Changelog-Generator
Show commit comments from all repos within the given timeframe.
This bash script is intended for Android developers and ROM maintainers who want to get a list of changes since their last release. It runs **git log** on all the git repositories under the Android tree root and prints the relevant commit messages.

Usage:
	changelog.sh [-p|--progress] &lt;since_date&gt; [&lt;until_date&gt;]

Must be run from the top of tree (try running 'croot' first)

&lt;since_date&gt;
	Show commits more recent than a specific date.

&lt;until_date&gt;
	Show commits older than a specific date.


If &lt;until_date&gt; is omitted then all commits from &lt;since_date&gt; until now are included.

Example:

	changelog.sh "2015-04-09T00:00:01Z" "2015-04-14T04:25:00Z"



