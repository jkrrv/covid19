git pull --rebase

matlab -wait -nodesktop -nosplash -r "run %cd%\covid.m; exit"

cd out

git add *

git commit -m "Auto-Update Data"
git push