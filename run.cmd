git pull --rebase

matlab -wait -nodesktop -nosplash -r "run %cd%\covid.m; exit"

git add imgs/*

git commit -m "Auto-update Images"
git push