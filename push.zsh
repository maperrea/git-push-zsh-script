#!/bin/zsh
git add -N -A
git diff --cached --exit-code >/dev/null
cached=$?
if [[ $cached -eq 129 ]]; then
	exit
fi
git diff --exit-code >/dev/null
ncached=$?
if [[ $cached -eq 0 && $ncached -eq 0 ]]; then
	while true; do
		echo -n "No changes to be commited. Do you still wish to continue? [y/n]: "
		read yn
		case $yn in
			Y | y)
				nochange=1
				break;;
			N | n)
				exit;;
		esac
	done
fi
git status -s
if [[ $1 == "-fast" ]]; then
	git add -A
	git commit -m "Default fast commit message"
	git push $2 $3
	exit
fi
while true; do
	if [[ $nochange -ne 1 ]]; then
		echo -n "Do you wish to add all and push? [y/n]: "
		read yn
	else
		yn="y"
	fi
	case $yn in
		Y | y )
			git add -A
			message=""
			while [[ ! -n $message ]]; do
				echo -n "Please enter a commit message: "
				read message
			done
			git commit -m "$message"
			git push $1 $2
			if [[ $? -ne 0 ]]; then
				while true; do
					echo "\nPlease enter a correct repository and branch"
					echo "You can set it as default with --set-upstream\n"
					echo "Available branches:"
					git branch
					echo "\nAvailable remotes:"
					git remote show
					echo "\ntype exit to abort\n"
					echo -n "git push "
					read repo
					if [[ $repo == "exit" ]]; then
						exit
					fi
					git push ${=repo}
					if [[ $? -eq 0 ]]; then
						exit
					fi
				done
			fi
			exit;;
		N | n )
			exit;;
	esac
done
