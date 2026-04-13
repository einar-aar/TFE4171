cp -r ../dd2master/ex-1 ~/
cp ../dd2master/.bashrc ~/
source .bashrc
./run_tb.scr
./lab1/run_tb.scr
cd lab1
./run_tb.scr
cd lab1
./run_tb.scr
cp ../dd2master/.bashrc ~/
cd ../
cp ../dd2master/.bashrc ~/
cd ../
cp ../dd2master/.bashrc ~/
source .bashrc
cd ex1
cd EX-1
ls
cd ex-1
cd lab1
./run_tb.scr
nl -ba ./rtl/NtnuTfe4171Lab1Fifo.sv | sed -n '45,55p'
./run_tb.scr
rm -rf .git
git status
cd ../
git init
git add .
cd ../
ls
git init
git add .
git config pull.rebase false
git status
git config --global user.email "einar@skogn.no"
git config --global user.name "einaraar"
git remote add origin https://github.com/einar-aar/TFE4171.git
git branch -M main
git status
cd lab1
./run_tb.scr
git fetch
cd ../
git fetch
git pull
./run_tb.scr
cd lab1
./run_tb.scr
git commit --amend
cd lab1
./run_synth.scr
./run_tc.scr
./lab1/run_tc.scr
cd lab1
./run_tb.scr
./run_synth.scr
cd lab1
./run_synth.scr
cd lab1
./run_synth.scr
cd lab1
./run_synth.scr
cd lab1
./run_tb.scr
cd lab1
./run_tb.scr
cd lab1
./run_synth.scr
cd lab1
./run_tb.scr
./lab1/run_tb.scr
cd lab1
./run_tb.scr
cd lab1
./run_tb.scr
cd ex-1
cd lab1
ls
./run_tb.scr
clear
./run_tb.scr
cd lab1
./run_tb.scr
cd lab1
less run_fifo.log
cd lab1
./run_tb.scr
./run_synth.scr
cd lab1
./run_synth.scr
cd lab1
./run_synth.scr
cd ex-1/lab1
ls
./run_tb.scr
clear
./run_tb.scr
clear
./run_tb.scr
cd lab1
./run_synth.scr
cd lab1
./run_synth.scr
git status
git checkout main
git pull
git merge Einar
git push
git checkout Einar
git merge main
git pull
git checkout main
cd lab1
./run_synth
./run_synth.scr
cd ex-1/lab1
ls
./run_tb.scr
cd ../
git pull
git pull Einar
git pull
git pull remote Einar
git pull origin Einar
cd lab1
./run_tb.scr
./synthesis.tcl
./run_tb.scr
./synthesis.tcl
./run_synth.scr
cd lab1
./run_tb.scr
./run_synth.scr
cd
cd lab1
./run_tb.scr
./run_synth.scr
cd lab1
./run_synth.scr
./run_tb.scr
vdir work
grep -n "module test_" ./lab1/tb/test_NtnuTfe4171Lab1Fifo.sv.architecturalTest.sv
./run_tb.scr
grep -n "module test_" ./lab1/tb/test_NtnuTfe4171Lab1Fifo.sv.architecturalTest.sv
./run_tb.scr
grep -n "module test_" ./lab1/tb/test_NtnuTfe4171Lab1Fifo.sv.architecturalTest.sv
find . -name "*architecturalTest*"
./run_tb.scr
cd ../
git status
git checkout main
git pull origin main
git merge Einar
cd lab1
./run_tb.scr
pandoc README.md -o README.pdf
sudo apt update
module avail pandoc
cp ../dd2master/lab2Release.tar.gz ./
ls
tar -xvzf lab2Release.tar.gz
ls
cd ex-1
mv .git ..
ls -a
mv .git ..
cd ..
git status
ls -a
rm -rf ex-1/.git
git add ex-1
git commit -m "Fixed nested repo"
git push
git remote add origin https://github.com/einar-aar/TFE4171
git remote -v
git push -u origin main
git push -u origin master
echo ".vscode-server/" >> .gitignore
echo "work/" >> .gitignore
echo "*.log" >> .gitignore
git rm -r --cached .vscode-server
git add .gitignore
git push
git push --set-upstream origin master
git rm -r --cached .vscode-server
git commit -m "Remove .vscode-server from repo"
 git rm -r --cached .vscode-server
git filter-branch --force --index-filter 'git rm -r --cached --ignore-unmatch .vscode-server' --prune-empty --tag-name-filter cat -- --all
git push --force --set-upstream origin master
cd lab2Release
./run_tb.scr
ls
cd lab2Release
ls
./run_tb.scr
ls
cd lab2Release
ls
./run_tb.scr
ls
cd lab2Release
./run_tb.scr
ls
git branch
git update
git refresh
git pull
git branch
git cheackout -b Daniel
git checkout Daniel
git branch -b Daniel
git branch Daniel
git branch
git cheackout Daniel
git checkout Daniel
git branch
ls
cd lab2Release
ls
run_tb.scr
.\ run_tb.scr
.\run_tb.scr
ls
/run_tb.scr
.run_tb.scr
./run_tb.scr
./
ls
..
cd ..
ls
tar -xvzf lab2Release.tar.gz
git branch
ls
git branch -D einar                # slett lokal
git push origin --delete einar     # slett remote
git checkout master
git checkout -b einar
git push -u origin einar
git branch -D Einar
git pull
git fetch origin
git branch -r | grep Einar
git checkout master
git checkout einar
git pull
git checkout -B Einar
git push origin --delete Einar
git pull
git checkout master
git branch -D Einar
cd lab2Release
./run_tb.scr
git config pull.rebase false
./run_tb.scr
cd lab2Release
ls
./run_tb.scr
vsim -c -coverage work.test_NtnuTfe4171Lab1Fifo -voptargs="+cover=sbceft" -do "run -all; coverage save -onexit -codeAll -cvg coverage.ucdb; exit"
vcover report -details coverage.ucdb
./run_tb.scr
vcover report -details coverage.ucdb
./run_tb.scr
vcover report -details coverage.ucdb
vcover report -html -htmldir htmlReport -details coverage.ucdb
vcover report -html -output htmlReport -details coverage.ucdb
./run_tb.scr
vcover report -details coverage.ucdb
./run_tb.scr
vcover report -details coverage.ucdb
find . -name "coverage.ucdb"
sudo find / -name "coverage.ucdb" 2>/dev/null
find / -iname "coverage.ucdb" 2>/dev/null
./run_tb.scr
sudo find / -name "coverage.ucdb" 2>/dev/null
find . -name "coverage.ucdb"
./run_tb.scr
find . -name "coverage.ucdb"
sudo find / -name "coverage.ucdb" 2>/dev/null
vcover report -details coverage.ucdb
cd lab2Release
./run_tb.scr
vcover report -details coverage.ucdb
./run_tb.scr
vcover report -details coverage.ucdb
./run_tb.scr
vcover report -details coverage.ucdb
cd
ls
cd lab2Release/
ls
./run_tb.scr
./coverage_command.src
./coverage_command.scr
vsim -c -coverage work.test_NtnuTfe4171Lab1Fifo -voptargs="+cover=sbceft" -do "run -all; coverage save -onexit -codeAll -cvg coverage.ucdb; exit"
vsim -c -coverage work.test_NtnuTfe4171Lab1Fifo -voptargs="+cover=sbceft" \
vsim -c -coverage work.test_NtnuTfe4171Lab2Fifo \ 
-voptargs="+cover=sbceft" -do "run -all; coverage save -onexit -codeAll -cvg coverage.ucdb; exit"
vsim -c -coverage work.test_NtnuTfe4171Lab2Fifo \ 
-voptargs="+cover=sbceft" \
clear
vsim -c -coverage work.test_NtnuTfe4171Lab2Fifo \ -voptargs="+cover=sbceft" \-do "run -all; coverage save -onexit -codeAll -cvg coverage.ucdb; exit"
./run_tb.scr
vcover report -html -htmldir htmlReport -details coverage.ucdb
vcover report -html -output htmlReport -details coverage.ucdb
ls
cd..
cd ..
ls
cd lab2Release/
ls
vcover report -details coverage.ucdb
./run_tb.scr
run -all
ls
cd lab2Release
./run_tb.scr
cd hdlc
./simulate.sh
./tb/simulate.sh
cd tb
./simulate.sh
ls
cp -r ../dd2master/termproject/hdlc ~/
./simulate.sh
ls
cd hdlc
cd tb
ls
./simulate.sh
ls
cd ..
ls
cp -r ../dd2master/termproject/hdlc ~/
cd hdlc/tb
ls
./simulate.sh
cd hdlc
cd tb
./simulate.sh
onespin
cp -r /home/courses/desdigsys2/2026s/dd2master/projects .
onespin
cp -r /home/courses/desdigsys2/2026s/dd2master/projects .
onespin
git fetch
cd ..
ls
cd dd2master
ls
sudo ls
cd ..
cd dds226s15
ls
cp -r ../dds2master/ex-4 .
cp -r ../dds2master/ex4 .
cp -r ../dds2master/lab4 .
cp -r ../dds2master/lab4release .
onespin
./simulate.sh
.tb//simulate.sh
./tb/simulate.sh
cd tb
./simulate.sh
