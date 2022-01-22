git config --local user.email " 96889255+OrchardForexTutorials@users.noreply.github.com"

git checkout --orphan latest_branch

git add -A

git commit -am "For Video"

git branch -D main

git branch -m main

git push -f origin main

pause