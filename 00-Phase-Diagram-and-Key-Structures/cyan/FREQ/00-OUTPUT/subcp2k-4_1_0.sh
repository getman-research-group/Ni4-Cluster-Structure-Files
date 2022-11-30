#/bin/bash 
#PBS -N 248-068_Zr18_C264_Ni4_O104_H188_UKS-multi9
#PBS -l select=1:ncpus=16:mpiprocs=16:mem=120gb:interconnect=fdr,walltime=72:00:00
#PBS -q work1 
#PBS -j oe
#PBS -m abe
#PBS -M svicchi@g.clemson.edu

echo ''
echo ' # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # '
echo ''
echo ' STARTING THE CALCULATION!'
echo ''
echo ' # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # '
echo '' 

cd ${PBS_O_WORKDIR}
 
qstat -xf $PBS_JOBID 

node_info_full=$(qstat -n $PBS_JOBID | tail -1 )
node_info_cut=$( echo ${node_info_full} | cut -c1-8 )
node_info=$( pbsnodes ${node_info_cut} )  
echo ${node_info} > ${PBS_O_WORKDIR}/temp.txt
sed 's/\s\+/\n/g' ${PBS_O_WORKDIR}/temp.txt >> ${PBS_O_WORKDIR}/temp1.txt 
line_number_resources_availible=$(grep -A 2 "resources_available.phase" ${PBS_O_WORKDIR}/temp1.txt)
echo -e 'Node: ' ${node_info_cut} > ${PBS_O_WORKDIR}/zp-phase.PHASE 
echo -e 'The calculation is currently running on: \n' ${line_number_resources_availible} >> ${PBS_O_WORKDIR}/zp-phase.PHASE
rm ${PBS_O_WORKDIR}/temp.txt ${PBS_O_WORKDIR}/temp1.txt
 
# Starting the CP2K calculation 
module purge
export MODULEPATH=/software/ModuleFiles/modules/linux-centos8-ivybridge:$MODULEPATH
module load cp2k/7.1-gcc/8.3.1-mpi
module list 
export OMP_NUM_THREADS=1

# Creating the CP2K scratch directory
SCRATCH_DIR="/scratch2/$USER/CP2K-${PBS_JOBID}/"
mkdir -p ${SCRATCH_DIR}
cp ${PBS_O_WORKDIR}/* ${SCRATCH_DIR}/.
echo ${SCRATCH_DIR} > ${PBS_O_WORKDIR}/zb-TO-SCRATCH.dir
echo ${PBS_O_WORKDIR} > ${SCRATCH_DIR}/zb-TO-PBS-WORKDIR.dir
echo '' > ${PBS_O_WORKDIR}/zc-${PBS_JOBID%.*}.JOBID
 
# Running CP2K
cd ${SCRATCH_DIR}
rm ${SCRATCH_DIR}/README.README
NAME=$(basename $(find . -maxdepth 1 -name "*.inp") .inp)
mpirun -n 16 cp2k.popt -i ${NAME}.inp -o ${NAME}.out

# Copying over all the raw output files from CP2K
mkdir -p ${PBS_O_WORKDIR}/00-OUTPUT 
cp ${SCRATCH_DIR}/* ${PBS_O_WORKDIR}/00-OUTPUT
if [[ -e ${PBS_O_WORKDIR}/00-OUTPUT/zb-TO-PBS-WORKDIR.dir ]]; then 
	rm ${PBS_O_WORKDIR}/00-OUTPUT/zb-TO-PBS-WORKDIR.dir
fi 

# Creating the visualization directory 
mkdir -p ${PBS_O_WORKDIR}/01-VIS 
declare -a COPY_LIST=("*xyz")
for i in "${COPY_LIST[@]}"; do
	cp ${PBS_O_WORKDIR}/00-OUTPUT/${i} ${PBS_O_WORKDIR}/01-VIS/. 
done 

# Creating job restart directory
mkdir -p ${PBS_O_WORKDIR}/02-RESTART 
declare -a COPY_LIST=("*.restart" "*-RESTART.wfn" "BASIS_file" "POTENTIALS_file" "dftd3.dat")
for i in "${COPY_LIST[@]}"; do
	cp ${PBS_O_WORKDIR}/00-OUTPUT/${i} ${PBS_O_WORKDIR}/02-RESTART/. 
done 
cp ${PBS_O_WORKDIR}/02-RESTART/*.restart ${PBS_O_WORKDIR}/02-RESTART/${NAME}.inp
cp ${PBS_O_WORKDIR}/*.sh ${PBS_O_WORKDIR}/02-RESTART/.
number_of_step=$(grep "     STEP_START_VAL "  ${PBS_O_WORKDIR}/02-RESTART/${NAME}.inp)
sed -i "s/${number_of_step}/     STEP_START_VAL  0/g" ${PBS_O_WORKDIR}/02-RESTART/${NAME}.inp

# Creating converged structure .xyz file 
cd ${PBS_O_WORKDIR}/00-OUTPUT
file_xyz=$(find . -type f -name "*.xyz")
number_atoms=`expr $(head -1 ${file_xyz}) + 2`
tail -${number_atoms} ${file_xyz} >> ${file_xyz%.*}-converged.xyz
echo ${file_xyz%.*}
cp2k-periodicity.py -i ${NAME}.inp -x ${file_xyz}
cp ${PBS_O_WORKDIR}/00-OUTPUT/*.xyz ${PBS_O_WORKDIR}/01-VIS/.   

# ENDING THE JOB
echo ''
echo ' # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # '
echo ''
echo ' ENDING THE CALCULATION!'
echo ''
echo ' # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # '
echo ''

qstat -xf $PBS_JOBID
rm -f core.*


