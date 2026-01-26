# .bashrc                                                                                                                        
                                                                                                                                 
# Source global definitions                                                                                                      
if [ -f /etc/bashrc ]; then                                                                                                      
        . /etc/bashrc                                                                                                            
fi                                                                                                                               
                                                                                                                                 
# User specific aliases and functions                                                                                            
#export PS1='\w`hg prompt "[{branch}{status}]" 2>/dev/null` $'

QUESTA_HOME=/eda/tools/siemens/questasim.2025.2
export PATH=$PATH:$QUESTA_HOME/bin
export SALT_LICENSE_SERVER=1717@europa.tele.ntnu.no:5280@europa.tele.ntnu.no:1700@europa.tele.ntnu.no:1720@europa.tele.ntnu.no

export LM_LICENSE_FILE=1717@europa.tele.ntnu.no:5280@europa.tele.ntnu.no:1700@europa.tele.ntnu.no:1720@europa.tele.ntnu.no
export OSSLMGR_LICENSE_FILE=1720@europa.tele.ntnu.no

export ONESPINROOT=/eda/tools/siemens/onespin.2024.3_2/onespin
export PATH=$ONESPINROOT/bin:$PATH

export PATH=/eda/tools/cadence/ddi.23.14.000/GENUS231/bin:$PATH
export PATH=$PATH:/eda/tools/synopsys/dc.w-2024.09-sp4/bin

