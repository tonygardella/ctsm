#!/bin/sh 
#

# test_driver.sh:  driver script for the offline testing of CLM
#
# usage on bangkok, calgary, breeze, bluevista, lightning, bluefire, jaguar, kraken: 
# ./test_driver.sh
#
# valid arguments: 
# -i    interactive usage
# -d    debug usage -- display tests that will run -- but do NOT actually execute them
# -f    force batch submission (avoids user prompt)
# -h    displays this help message
#
# **pass environment variables by preceding above commands 
#   with 'env var1=setting var2=setting '
# **more details in the CLM testing user's guide, accessible 
#   from the CLM developers web page


#will attach timestamp onto end of script name to prevent overwriting
cur_time=`date '+%H:%M:%S'`
seqccsm_vers="ccsm4_0_alpha34"

hostname=`hostname`
case $hostname in

    ##bluevista
    bv* )
    submit_script="test_driver_bluevista_${cur_time}.sh"

    account_name=`grep -i "^${LOGNAME}:" /etc/project.ncar | cut -f 2 -d "," | cut -f 3 -d ":" `
    if [ ! -n "${account_name}" ]; then
	echo "ERROR: unable to locate an account number to charge for this job under user: $LOGNAME"
	exit 2
    fi

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat > ./${submit_script} << EOF
#!/bin/sh
#

#BSUB -a poe                    # use LSF poe elim
#BSUB -n 32                     # total tasks needed
#BSUB -R "span[ptile=16]"       # max number of tasks (MPI) per node
#BSUB -o test_dr.o%J            # output filename
#BSUB -e test_dr.o%J            # error filename
#BSUB -J clmtest
#BSUB -q regular                # queue
#BSUB -W 6:00                     
#BSUB -P $account_name      
#BSUB -x                        # exclusive use of node (not_shared)
##BSUB -q share
##BSUB -W 0:50
##BSUB -P 00000006

if [ -n "\$LSB_JOBID" ]; then   #batch job
    export JOBID=\${LSB_JOBID}
    initdir=\${LS_SUBCWD}
    interactive="NO"
else
    interactive="YES"
    export LSB_MCPU_HOSTS="\$hostname 16"
fi

##omp threads
export CLM_THREADS=4
export CLM_RESTART_THREADS=8

##mpi tasks
export CLM_TASKS=8
export CLM_RESTART_TASKS=4

export CLM_COMPSET="I"

export INC_NETCDF=/usr/local/include
export LIB_NETCDF=/usr/local/lib64/r4i4
export AIXTHREAD_SCOPE=S
export MALLOCMULTIHEAP=true
export OMP_DYNAMIC=false
export XLSMPOPTS="stack=40000000"
export MAKE_CMD="gmake -j 8"
export CFG_STRING=""
export TOOLS_MAKE_STRING=""
export CCSM_MACH="bluevista"
export MACH_WORKSPACE="/ptmp"
export CPRNC_EXE=/contrib/newcprnc3.0/bin/newcprnc
export DATM_DATA_DIR=/cgd/tss/NCEPDATA.datm7.Qian.T62.c060410
dataroot="/fs/cgd/csm"
echo_arg=""
input_file="tests_pretag_bluevista"

EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^
    ;;

    ##bluefire
    be* )
    submit_script="test_driver_bluefire${cur_time}.sh"

    account_name=`grep -i "^${LOGNAME}:" /etc/project.ncar | cut -f 1 -d "," | cut -f 2 -d ":" `
    if [ ! -n "${account_name}" ]; then
	echo "ERROR: unable to locate an account number to charge for this job under user: $LOGNAME"
	exit 2
    fi

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat > ./${submit_script} << EOF
#!/bin/sh
#

#BSUB -a poe                      # use LSF poe elim
#BSUB -x                          # exclusive use of node (not_shared)
#BSUB -n 16                       # total tasks needed
#BSUB -R "span[ptile=64]"         # max number of tasks (MPI) per node
#BSUB -o test_dr.o%J              # output filename
#BSUB -e test_dr.o%J              # error filename
#BSUB -q regular                  # queue
#BSUB -W 6:00                     
#BSUB -P $account_name      
#BSUB -J clmtest

if [ -n "\$LSB_JOBID" ]; then   #batch job
    export JOBID=\${LSB_JOBID}
    initdir=\${LS_SUBCWD}
    interactive="NO"
else
    interactive="YES"
    export LSB_MCPU_HOSTS="\$hostname 8"
fi

##omp threads
export CLM_THREADS=2
export CLM_RESTART_THREADS=4

##mpi tasks
export CLM_TASKS=16
export CLM_RESTART_TASKS=8

export CLM_COMPSET="I"

export INC_NETCDF=/usr/local/apps/netcdf-3.6.1/include
export LIB_NETCDF=/usr/local/apps/netcdf-3.6.1/lib
export AIXTHREAD_SCOPE=S
export MALLOCMULTIHEAP=true
export OMP_DYNAMIC=false
export XLSMPOPTS="stack=40000000"
export MAKE_CMD="gmake -j 65"
export CFG_STRING=""
export TOOLS_MAKE_STRING=""
export CCSM_MACH="bluefire"
export MACH_WORKSPACE="/ptmp"
CPRNC_EXE="/contrib/newcprnc3.0/bin/newcprnc"
newcprnc="\$MACH_WORKSPACE/\$LOGIN/newcprnc"
/bin/cp -fp \$CPRNC_EXE \$newcprnc
export CPRNC_EXE="\$newcprnc"
export DATM_DATA_DIR="/cgd/tss/NCEPDATA.datm7.Qian.T62.c060410"
dataroot="/fs/cgd/csm"
echo_arg=""
input_file="tests_pretag_bluefire"

EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^
    ;;


    ##lightning
    ln* )
    submit_script="test_driver_lightning_${cur_time}.sh"

    account_name=`grep -i "^${LOGNAME}:" /etc/project | cut -f 1 -d "," | cut -f 2 -d ":" `
    if [ ! -n "${account_name}" ]; then
	echo "ERROR: unable to locate an account number to charge for this job under user: $LOGNAME"
	exit 2
    fi

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat > ./${submit_script} << EOF
#!/bin/sh
#

#BSUB -a mpich_gm            #lightning requirement
#BSUB -x                     # exclusive use of node (not_shared)
#BSUB -n 32                  # total tasks needed
#BSUB -o test_dr.o%J         # output filename
#BSUB -e test_dr.o%J         # error filename
#BSUB -q regular             # queue
#BSUB -W 6:00                     
#BSUB -P $account_name      
#BSUB -J clmtest

if [ -n "\$LSB_JOBID" ]; then   #batch job
    export JOBID=\${LSB_JOBID}
    initdir=\${LS_SUBCWD}
    interactive="NO"
else
    interactive="YES"
    export LSB_MCPU_HOSTS="\$hostname 8"
fi

##omp threads
export CLM_THREADS=1
export CLM_RESTART_THREADS=2

##mpi tasks
export CLM_TASKS=32
export CLM_RESTART_TASKS=16

export CLM_COMPSET="I"

if [ "\$CLM_FC" = "ifort" ]; then
   netcdf=/contrib/2.6/netcdf/3.6.2-intel-10.1.008-64
   export INC_NETCDF=\$netcdf/include
   export LIB_NETCDF=\$netcdf/lib
   mpich=/contrib/2.6/mpich-gm/1.2.6..14a-intel-10.1.008-64
   export INC_MPI=\${mpich}/include
   export LIB_MPI=\${mpich}/lib
   export intel=/contrib/2.6/intel/10.1.008
   export PATH=\${mpich}/bin:\${intel}/bin:\${PATH}
   export MAKE_CMD="gmake"
   export CFG_STRING="-fc ifort -cc icc -linker \$mpich/bin/mpif90 "
   export TOOLS_MAKE_STRING="USER_FC=ifort USER_LINKER=ifort "
else
   export INC_NETCDF=/contrib/2.6/netcdf/3.6.0-p1-pathscale-2.4-64/include
   export LIB_NETCDF=/contrib/2.6/netcdf/3.6.0-p1-pathscale-2.4-64/lib
   mpich=/contrib/2.6/mpich-gm/1.2.6..14a-pathscale-2.4-64
   export INC_MPI=\${mpich}/include
   export LIB_MPI=\${mpich}/lib
   export PS=/contrib/2.6/pathscale/2.4
   export PATH=\${mpich}/bin:\${PS}/bin:\${PATH}
   export LD_LIBRARY_PATH=\${PS}/lib/2.4:/opt/pathscale/lib/2.4/32:\${LD_LIBRARY_PATH}
   export MAKE_CMD="gmake -j 4"
   export CFG_STRING="-fc pathf90 -linker \${mpich}/bin/mpif90 "
   export TOOLS_MAKE_STRING="USER_FC=pathf90 USER_LINKER=\${mpich}/bin/mpif90 "
fi
export CCSM_MACH="lightning"
export MACH_WORKSPACE="/ptmp"
export CPRNC_EXE=/contrib/newcprnc3.0/bin/newcprnc
export DATM_DATA_DIR=/cgd/tss/NCEPDATA.datm7.Qian.T62.c060410
dataroot="/fs/cgd/csm"
echo_arg="-e"
input_file="tests_posttag_lightning"

EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^
    ;;

    ##breeze
    breeze | gale | gust | hail )
    submit_script="test_driver_breeze_${cur_time}.sh"

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat > ./${submit_script} << EOF
#!/bin/sh
#

interactive="YES"

##omp threads
export CLM_THREADS=2
export CLM_RESTART_THREADS=2

##mpi tasks
export CLM_TASKS=2
export CLM_RESTART_TASKS=1

export CLM_COMPSET="I"

netcdf=/contrib/netcdf-3.6.2/intel
export INC_NETCDF=\$netcdf/include
export LIB_NETCDF=\$netcdf/lib
export intel=/fs/local
export PATH=\${intel}/bin:\${PATH}
export MAKE_CMD="gmake -j5 "
export CFG_STRING="-fc ifort -cc icc "
export TOOLS_MAKE_STRING="USER_FC=ifort USER_LINKER=ifort "
export CCSM_MACH="breeze"
export MACH_WORKSPACE="/ptmp"
export DATM_DATA_DIR="/cgd/tss/NCEPDATA.datm7.Qian.T62.c060410"
dataroot="/fis/cgd/cseg/csm"
echo_arg="-e"
input_file="tests_posttag_breeze"

EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^
    ;;

    ##bangkok,calgary
    ba* | b0* | ca* | c0* ) 
    submit_script="test_driver_bangkok_${cur_time}.sh"

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat > ./${submit_script} << EOF
#!/bin/sh
#

# Name of the queue (CHANGE THIS if needed)
#PBS -q long
# Number of nodes (CHANGE THIS if needed)
#PBS -l nodes=2:ppn=2
# output file base name
#PBS -N test_dr
# Put standard error and standard out in same file
#PBS -j oe
# Export all Environment variables
#PBS -V
# End of options

if [ -n "\$PBS_JOBID" ]; then    #batch job
    export JOBID=\`echo \${PBS_JOBID} | cut -f1 -d'.'\`
    initdir=\${PBS_O_WORKDIR}
fi

if [ "\$PBS_ENVIRONMENT" = "PBS_BATCH" ]; then
    interactive="NO"
else
    interactive="YES"
fi

##omp threads
export CLM_THREADS=1
export CLM_RESTART_THREADS=2

##mpi tasks
export CLM_TASKS=4
export CLM_RESTART_TASKS=2

export CLM_COMPSET="I"

if [ "\$CLM_FC" = "PGI" ]; then
    export PGI=/usr/local/pgi-pgcc-pghf
    export INC_NETCDF=/usr/local/netcdf-pgi/include
    export LIB_NETCDF=/usr/local/netcdf-pgi/lib
    mpich=/usr/local/mpich-pgi-pgcc-pghf
    export INC_MPI=\${mpich}/include
    export LIB_MPI=\${mpich}/lib
    export PATH=\${PGI}/linux86/6.1/bin:\${mpich}/bin:\${PATH}
    export LD_LIBRARY_PATH=\${PGI}/linux86/6.1/lib:\${LD_LIBRARY_PATH}
    export CFG_STRING=""
    export TOOLS_MAKE_STRING=""
else
    export LAHEY=/usr/local/lf9562
    export INC_NETCDF=/usr/local/netcdf-gcc-lf95/include
    export LIB_NETCDF=/usr/local/netcdf-gcc-lf95/lib
    mpich=/usr/local/mpich-gcc-g++-lf95
    export INC_MPI=\${mpich}/include
    export LIB_MPI=\${mpich}/lib
    export PATH=\${LAHEY}/bin:\${mpich}/bin:\${PATH}
    export CFG_STRING="-fc lf95 "
    export TOOLS_MAKE_STRING="USER_FC=lf95 USER_LINKER=lf95 "
fi
export CCSM_MACH="bangkok"
export MAKE_CMD="gmake -j 2"   ##using hyper-threading on calgary
export MACH_WORKSPACE="/scratch/cluster"
export CPRNC_EXE=/contrib/newcprnc3.0/bin/newcprnc
export DATM_DATA_DIR=/project/tss/NCEPDATA.datm7.Qian.T62.c060410
dataroot="/fs/cgd/csm"
echo_arg="-e"
input_file="tests_pretag_bangkok"

EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^
    ;;


    ##jaguar
    jaguar* ) 
    submit_script="test_driver_jaguar_${cur_time}.sh"

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat > ./${submit_script} << EOF
#!/bin/sh
#

# Name of the queue (CHANGE THIS if needed)
# #PBS -q batch
# Number of nodes (CHANGE THIS if needed)
#PBS -l walltime=02:30:00,size=440
# output file base name
#PBS -N test_dr
# Put standard error and standard out in same file
#PBS -j oe
# Use sh
#PBS -S /bin/sh
# Export all Environment variables
#PBS -V
#PBS -A CLI017dev
# End of options

if [ -n "\$PBS_JOBID" ]; then    #batch job
    export JOBID=\`echo \${PBS_JOBID} | cut -f1 -d'.'\`
    initdir=\${PBS_O_WORKDIR}
fi

echo_arg="-e"
if [ "\$PBS_ENVIRONMENT" = "PBS_BATCH" ]; then
    interactive="NO"
else
    interactive="YES"
fi

input_file="tests_pretag_jaguar"

##omp threads
export CLM_THREADS=1
export CLM_RESTART_THREADS=4

##mpi tasks
export CLM_TASKS=440
export CLM_RESTART_TASKS=110

export CLM_COMPSET="I"

source /opt/modules/default/init/sh
module purge
module load   PrgEnv-pgi Base-opts
module switch xt-mpt xt-mpt/2.0.49a
module load   torque moab
module load   netcdf/3.6.2
module load   ncl
export PATH="/opt/public/bin:/opt/cray/bin:/usr/bin/X11"
export PATH="\${PATH}:\${MPICH_DIR}/bin"
export PATH="\${PATH}:\${PE_DIR}/bin/snos64"
export PATH="\${PATH}:\${PGI}/linux86-64/default/bin"
export PATH="\${PATH}:\${SE_DIR}/bin/snos64"
export PATH="\${PATH}:\${C_DIR}/amd64/bin"
export PATH="\${PATH}:\${PRGENV_DIR}/bin"
export PATH="\${PATH}:\${MPT_DIR}/bin"
export PATH="\${PATH}:/usr/bin:/bin:/opt/bin:/sbin:/usr/sbin:/apps/jaguar/bin"

export LIB_NETCDF=\${NETCDF_DIR}/lib
export INC_NETCDF=\${NETCDF_DIR}/include
export MOD_NETCDF=\${NETCDF_DIR}/include
export CCSM_MACH="jaguar"
export CFG_STRING="-fc ftn "
export TOOLS_MAKE_STRING="USER_FC=ftn USER_CC=cc "
export MAKE_CMD="gmake -j 9 "
export MACH_WORKSPACE="/tmp/work"
export CPRNC_EXE=/spin/proj/ccsm/bin/jaguar/newcprnc
export DATM_DATA_DIR=/tmp/proj/ccsm/inputdata/atm/datm7/NCEPDATA.datm7.Qian.T62.c060410
dataroot="/tmp/proj/ccsm"
EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^
    ;;

    ##kraken
    kraken* ) 
    submit_script="test_driver_kraken_${cur_time}.sh"

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat > ./${submit_script} << EOF
#!/bin/sh
#

# Name of the queue (CHANGE THIS if needed)
### #PBS -q debug
# #PBS -q small
# Number of nodes (CHANGE THIS if needed)
#PBS -l walltime=02:00:00,size=200
# output file base name
#PBS -N test_dr
# Put standard error and standard out in same file
#PBS -j oe
# Use sh
#PBS -S /bin/sh
# Export all Environment variables
#PBS -V
#PBS -A UT-NTNL0001
# End of options

if [ -n "\$PBS_JOBID" ]; then    #batch job
    export JOBID=\`echo \${PBS_JOBID} | cut -f1 -d'.'\`
    initdir=\${PBS_O_WORKDIR}
fi

echo_arg="-e"
if [ "\$PBS_ENVIRONMENT" = "PBS_BATCH" ]; then
    interactive="NO"
else
    interactive="YES"
fi

input_file="tests_posttag_kraken"

##omp threads
export CLM_THREADS=1
export CLM_RESTART_THREADS=4

##mpi tasks
export CLM_TASKS=200
export CLM_RESTART_TASKS=50

export CLM_COMPSET="I"

export PATH="/usr/bin/X11"
export PATH="\${PATH}:/usr/bin:/bin:/sbin:/usr/sbin"

if [ -e /opt/modules/default/init/sh ]; then
  source /opt/modules/default/init/sh
  module purge
  module load PrgEnv-pgi Base-opts
  module load xtpe-quadcore
# module swap xt-mpt xt-mpt/3.0.0.0 # (3.0.0.0 is default on 2008-Aug-11)
  module load torque moab
  module switch pgi pgi/7.1.6       # (7.1.6   is default on 2008-Aug-11)
  module load netcdf/3.6.2
# module list
fi
export PATH="\${PATH}:\${MPICH_DIR}/bin"
export PATH="\${PATH}:\${PE_DIR}/bin/snos64"
export PATH="\${PATH}:\${PGI}/linux86-64/default/bin"
export PATH="\${PATH}:\${SE_DIR}/bin/snos64"
export PATH="\${PATH}:\${C_DIR}/amd64/bin"
export PATH="\${PATH}:\${PRGENV_DIR}/bin"
export PATH="\${PATH}:\${MPT_DIR}/bin"

export LIB_NETCDF=\${NETCDF_DIR}/lib
export INC_NETCDF=\${NETCDF_DIR}/include
export MOD_NETCDF=\${NETCDF_DIR}/include
export CCSM_MACH="kraken"
export CFG_STRING="-fc ftn "
export TOOLS_MAKE_STRING="USER_FC=ftn USER_CC=cc "
export MAKE_CMD="gmake -j 9 "
export MACH_WORKSPACE="/lustre/scratch"
export CPRNC_EXE="/lustre/scratch/proj/ccsm/bin/newcprnc"
export DATM_DATA_DIR="/lustre/scratch/proj/ccsm/inputdata/atm/datm7/NCEPDATA.datm7.Qian.T62.c060410"
dataroot="/lustre/scratch/proj/ccsm"
EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^
    ;;

    ##aluminum
    aluminum* )
    submit_script="test_driver_spot1_${cur_time}.sh"

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat > ./${submit_script} << EOF
#!/bin/sh
#

interactive="YES"

##omp threads
export CLM_THREADS=2
export CLM_RESTART_THREADS=1

##mpi tasks
export CLM_TASKS=2
export CLM_RESTART_TASKS=1

export CLM_COMPSET="I"

export CCSM_MACH="none"
export INC_NETCDF=/usr/local/netcdf-3.6.1..0-p1/include
export LIB_NETCDF=/usr/local/netcdf-3.6.1..0-p1/lib
export MAKE_CMD="make -j 4"
#export CFG_STRING="-fc g95 -cc gcc "
export CFG_STRING=""
export TOOLS_MAKE_STRING=""
export MACH_WORKSPACE="$HOME/runs"
export CPRNC_EXE=$HOME/bin/newcprnc
export DATM_DATA_DIR=$HOME/inputdata/atm/datm7/NCEPDATA.datm7.Qian.T62.c060410
dataroot="$HOME"
echo_arg=""
input_file="tests_posttag_spot1"

EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^
    ;;

    * ) echo "ERROR: machine $hostname not currently supported"; exit 1 ;;
esac

##vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv writing to batch script vvvvvvvvvvvvvvvvvvv
cat >> ./${submit_script} << EOF

if [ -n "\${CLM_JOBID}" ]; then
    export JOBID=\${CLM_JOBID}
fi
##check if interactive job

if [ "\$interactive" = "YES" ]; then

    if [ -z "\${JOBID}" ]; then
       export JOBID=\$\$
    fi
    echo "test_driver.sh: interactive run - setting JOBID to \$JOBID"
    if [ \$0 = "test_driver.sh" ]; then
	initdir="."
    else
	initdir=\${0%/*}
    fi
fi

##establish script dir and clm_root
if [ -f \${initdir}/test_driver.sh ]; then
    export CLM_SCRIPTDIR=\`cd \${initdir}; pwd \`
    export CLM_ROOT=\`cd \${CLM_SCRIPTDIR}/../../../../..; pwd \`
else
    if [ -n "\${CLM_ROOT}" ] && [ -f \${CLM_ROOT}/models/lnd/clm*/test/system/test_driver.sh ]; then
	export CLM_SCRIPTDIR=\`cd \${CLM_ROOT}/models/lnd/clm*/test/system; pwd \`
    else
	echo "ERROR: unable to determine script directory "
	echo "       if initiating batch job from directory other than the one containing test_driver.sh, "
	echo "       you must set the environment variable CLM_ROOT to the full path of directory containing "
        echo "       <models>. "
	exit 3
    fi
fi

##output files
clm_log=\${initdir}/td.\${JOBID}.log
if [ -f \$clm_log ]; then
    rm \$clm_log
fi
clm_status=\${initdir}/td.\${JOBID}.status
if [ -f \$clm_status ]; then
    rm \$clm_status
fi

##setup test work directory
if [ -z "\$CLM_TESTDIR" ]; then
    export CLM_TESTDIR=\${MACH_WORKSPACE}/\$LOGNAME/test-driver.\${JOBID}
    if [ -d \$CLM_TESTDIR ]; then
        rm -r \$CLM_TESTDIR
    fi
fi
if [ ! -d \$CLM_TESTDIR ]; then
    mkdir -p \$CLM_TESTDIR
    if [ \$? -ne 0 ]; then
	echo "ERROR: unable to create work directory \$CLM_TESTDIR"
	exit 4
    fi
fi

##set our own environment vars
export CSMDATA=\${dataroot}/inputdata
export MPI_TYPE_MAX=100000

##process other env vars possibly coming in
if [ -z "\$CLM_RETAIN_FILES" ]; then
    export CLM_RETAIN_FILES=FALSE
fi
if [ -z "\$CLM_SEQCCSMROOT" ]; then
    export CLM_SEQCCSMROOT="\${dataroot}/collections/${seqccsm_vers}"
fi
if [ -n "\${CLM_INPUT_TESTS}" ]; then
    input_file=\$CLM_INPUT_TESTS
else
    input_file=\${CLM_SCRIPTDIR}/\${input_file}
fi
if [ ! -f \${input_file} ]; then
    echo "ERROR: unable to locate input file \${input_file}"
    exit 5
fi

if [ \$interactive = "YES" ]; then
    echo "reading tests from \${input_file}"
else
    echo "reading tests from \${input_file}" >> \${clm_log}
fi

num_tests=\`wc -w < \${input_file}\`
echo "STATUS OF CLM TESTING UNDER JOB \${JOBID};  scheduled to run \$num_tests tests from:" >> \${clm_status}
echo "\$input_file" >> \${clm_status}
echo "" >> \${clm_status}
echo " on machine: $hostname" >> \${clm_status}
echo "tests of Sequential-CCSM will use source code from:" >> \${clm_status}
echo "\$CLM_SEQCCSMROOT" >> \${clm_status}
if [ -n "${BL_ROOT}" ]; then
   echo "tests of baseline will use source code from:" >> \${clm_status}
   echo "\$BL_ROOT" >> \${clm_status}
fi
if [ \$interactive = "NO" ]; then
    echo "see \${clm_log} for more detailed output" >> \${clm_status}
fi
echo "" >> \${clm_status}

test_list=""
while read input_line; do
    test_list="\${test_list}\${input_line} "
done < \${input_file}

##initialize flags, counter
skipped_tests="NO"
pending_tests="NO"
count=0

##loop through the tests of input file
for test_id in \${test_list}; do
    count=\`expr \$count + 1\`
    while [ \${#count} -lt 3 ]; do
        count="0\${count}"
    done

    master_line=\`grep \$test_id \${CLM_SCRIPTDIR}/input_tests_master\`
    status_out=""
    for arg in \${master_line}; do
        status_out="\${status_out}\${arg} "
    done

    if [ -z "\$status_out" ]; then
	echo "No test matches \$test_id in \${CLM_SCRIPTDIR}/input_tests_master"
        exit 3
    fi

    test_cmd=\${status_out#* }

    status_out="\${count} \${status_out}"

    if [ \$interactive = "YES" ]; then
        echo ""
        echo "***********************************************************************************"
        echo "\${status_out}"
        echo "***********************************************************************************"
    else
        echo "" >> \${clm_log}
        echo "***********************************************************************************"\
            >> \${clm_log}
        echo "\$status_out" >> \${clm_log}
        echo "***********************************************************************************"\
            >> \${clm_log}
    fi

    if [ \${#status_out} -gt 94 ]; then
        status_out=\`echo "\${status_out}" | cut -c1-100\`
    fi
    while [ \${#status_out} -lt 97 ]; do
        status_out="\${status_out}."
    done

    echo \$echo_arg "\$status_out\c" >> \${clm_status}

    if [   \$interactive = "YES" ]; then
        \${CLM_SCRIPTDIR}/\${test_cmd}
        rc=\$?
    else
        \${CLM_SCRIPTDIR}/\${test_cmd} >> \${clm_log} 2>&1
        rc=\$?
    fi
    if [ \$rc -eq 0 ]; then
        echo "PASS" >> \${clm_status}
    elif [ \$rc -eq 255 ]; then
        echo "SKIPPED*" >> \${clm_status}
        skipped_tests="YES"
    elif [ \$rc -eq 254 ]; then
        echo "PENDING**" >> \${clm_status}
        pending_tests="YES"
    else
        echo "FAIL! rc= \$rc" >> \${clm_status}
	if [ \$interactive = "YES" ]; then
	    if [ "\$CLM_SOFF" != "FALSE" ]; then
		echo "stopping on first failure"
		echo "stopping on first failure" >> \${clm_status}
		exit 6
	    fi
	else
	    if [ "\$CLM_SOFF" = "TRUE" ]; then
		echo "stopping on first failure" >> \${clm_status}
		echo "stopping on first failure" >> \${clm_log}
		exit 6
	    fi
	fi
    fi
done

echo "end of input" >> \${clm_status}
if [ \$interactive = "YES" ]; then
    echo "end of input"
else
    echo "end of input" >> \${clm_log}
fi

if [ \$skipped_tests = "YES" ]; then
    echo "*  please verify that any skipped tests are not required of your clm commit" >> \${clm_status}
fi
if [ \$pending_tests = "YES" ]; then
    echo "** tests that are pending must be checked manually for a successful completion" >> \${clm_status}
    if [ \$interactive = "NO" ]; then
	echo "   see the test's output in \${clm_log} " >> \${clm_status}
	echo "   for the location of test results" >> \${clm_status}
    fi
fi
exit 0

EOF
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ writing to batch script ^^^^^^^^^^^^^^^^^^^


chmod a+x $submit_script
arg1=${1##*-}
case $arg1 in
    [iI]* )
    debug="NO"
    interactive="YES"
    compile_only="NO"
    export debug
    export interactive
    export compile_only
    ./${submit_script}
    exit 0
    ;;

    [cC]* )
    debug="YES"
    interactive="YES"
    compile_only="YES"
    export debug
    export interactive
    export compile_only
    ./${submit_script}
    exit 0
    ;;

    [dD]* )
    debug="YES"
    interactive="YES"
    compile_only="NO"
    export debug
    export interactive
    export compile_only
    ./${submit_script}
    exit 0
    ;;

    [fF]* )
    debug="NO"
    interactive="NO"
    compile_only="NO"
    export debug
    export interactive
    export compile_only
    ;;

    "" )
    echo ""
    echo "**********************"
    echo "$submit_script has been created and will be submitted to the batch queue..."
    echo "(ret) to continue, (a) to abort"
    read ans
    case $ans in
	[aA]* ) 
	echo "aborting...type ./test_driver.sh -h for help message"
	exit 0
	;;
    esac
    debug="NO"
    interactive="NO"
    compile_only="NO"
    export debug
    export interactive
    export compile_only
    ;;

    * )
    echo ""
    echo "**********************"
    echo "usage on bangkok, bluevista, bluefire, lightning, jaguar, kraken: "
    echo "./test_driver.sh"
    echo ""
    echo "valid arguments: "
    echo "-i    interactive usage"
    echo "-c    compile-only usage (run configure and compile do not run clm)"
    echo "-d    debug-only  usage (run configure and build-namelist do NOT compile or run clm)"
    echo "-f    force batch submission (avoids user prompt)"
    echo "-h    displays this help message"
    echo ""
    echo "**pass environment variables by preceding above commands "
    echo "  with 'env var1=setting var2=setting '"
    echo "**more details in the CLM testing user's guide, accessible "
    echo "  from the CLM developers web page"
    echo ""
    echo "**********************"
    exit 0
    ;;
esac

echo "submitting..."
case $hostname in
    ##bluevista
    bv* )  bsub < ${submit_script};;

    ##bluefire
    be* )  bsub < ${submit_script};;

    ##lightning
    ln* )  bsub < ${submit_script};;

    ##bangkok,calgary
    ba* | b0* | ca* | c0* )  qsub ${submit_script};;

    ##jaguar
    jaguar* )  qsub ${submit_script};;

    ##kraken
    kraken* )  qsub ${submit_script};;

    #default
    * )
    echo "no submission capability on this machine"
    exit 0
    ;;

esac
exit 0
