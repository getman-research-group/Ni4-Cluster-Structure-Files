# Ni4-Cluster-Structure-Files

This repository contains all of the XYZ files for the paper *Computational and Experimental Characterization of the Ligand Environment of a Ni-Oxo Catalyst Supported in the Metal-Organic Framework NU-1000*. The files are the converged geometries from CP2K for the Ni4-cluster. 

The repository is organized according to the following: 
* [00-Phase-Diagram-and-Key-Structures](https://github.com/getman-research-group/Ni4-Cluster-Structure-Files/tree/main/00-Phase-Diagram-and-Key-Structures): All of the structures appearing on the phase diagram and the key structures based on dPDF. The electronic energies for the converged strucures and the frequency files are presented.
* [01-Less-Than-100-kJmol-Structures](https://github.com/getman-research-group/Ni4-Cluster-Structure-Files/tree/main/01-Less-Than-100-kJmol-Structures): All of the structures within 100 kJ/mol of the lowest energy configuration 
* [02-All-Structures](https://github.com/getman-research-group/Ni4-Cluster-Structure-Files/tree/main/02-All-Structures): All of the structures generated during modeling
* [03-Sample-Input-Files](https://github.com/getman-research-group/Ni4-Cluster-Structure-Files/tree/main/03-Sample-Input-Files): Sample input files for each CP2K calculation
  * GEO_OPT.inp : CP2K input file for geometry optimization 
  * FREQUENCY.inp : CP2K input file for a frequency optimization 
  * BASIS_file : basis set file for electronic structures
  * POTENTIALS_file : psuedopotential file for electronic structure 
  * dftd3.dat : dftb3 parameter file

