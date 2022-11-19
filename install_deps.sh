USER=$1

cd /home/${USER}/workspace/
git clone https://ceres-solver.googlesource.com/ceres-solver
cd /home/${USER}/workspace/ceres-solver
git checkout $(git describe --tags)
mkdir build
cd /home/${USER}/workspace/ceres-solver/build
cmake .. -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF
make -j
make install

cd /home/${USER}/workspace/
git clone https://github.com/colmap/colmap.git
cd /home/${USER}/workspace/colmap
mkdir build
cd /home/${USER}/workspace/colmap/build
cmake ..
make -j
make install

cd /home/${USER}/workspace/
git clone --recursive https://github.com/nvlabs/instant-ngp
cd /home/${USER}/workspace/instant-ngp/
cmake . -B build 
cmake --build build --config RelWithDebInfo -j

echo "Done"
