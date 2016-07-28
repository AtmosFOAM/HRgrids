#!/bin/bash -ve

# Create an OpenFOAM polyMesh and the dual mesh from patch data
rm -rf constant/polyMesh dualMesh/constant/polyMesh dualMeshTmp [0-9]*[0-9]

# First create the mesh from a patch
extrudeMesh

# Change the patches to "empty" to make it 2D and remove zero sized patches
sed -i 's/patch/empty/g' constant/polyMesh/boundary
sed -i -e '/sides/,+6d' constant/polyMesh/boundary
sed -i '18s/3/2/' constant/polyMesh/boundary

# renumber the mesh for better cache co-herencey
renumberMesh -constant -overwrite

# plot the mesh
gmtFoam -constant mesh
gv constant/mesh.pdf &

# create the dual mesh of triangular prisms first to a temporary new case
polyDualMesh 90
mkdir -p dualMeshTmp/constant
cp -r system dualMeshTmp
mv [0-9]*[0-9]/polyMesh dualMeshTmp/constant
rmdir [0-9]*[0-9]
rm *obj

# extract just one layer of the dual mesh to create a dualMesh as a region
extrudeMesh -case dualMesh

# remove the temporary dual
rm -r dualMeshTmp

# Change the patches to "empty" to make it 2D and remove zero sized patches
# for the dualMesh
sed -i 's/patch/empty/g' dualMesh/constant/polyMesh/boundary
sed -i -e '/sides/,+6d' dualMesh/constant/polyMesh/boundary
sed -i '18s/3/2/' dualMesh/constant/polyMesh/boundary

# plot the dual mesh
gmtFoam -constant mesh -case dualMesh
gv dualMesh/constant/mesh.pdf &

# Mesh checks
checkMesh -constant
checkMesh -constant -case dualMesh

