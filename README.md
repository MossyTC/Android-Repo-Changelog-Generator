# Android-Repo-Changelog-Generator
Show commit comments from all repos within the given timeframe.
This bash script is intended for Android developers and ROM maintainers who want to get a list of changes since their last release. It runs **git log** on all the git repositories under the Android tree root and prints the relevant commit messages.

Usage:
	changelog.sh timestamp-file [repolist-file]

Must be run from the top of tree (try running 'croot' first)

timestamp-file
    File containing a list of timestamps corresponding to repo syncs associated with each release. The last two timestamps will be used as the start and end times for the commit comments.

repolist-file
   The list of repositories from which commit comments are to be retrieved. If not speicifed then commit comments from all repositories will be retrieved.



Example:

	changelog.sh repostamp.txt repolist.txt


