if [ "$1" ]; then
  LOG_DIR=$1
  mkdir -p $LOG_DIR
else
  echo 'Must specify output log directory'
  exit 1
fi

if [ -z $OSU_PATH_SGIMPT ]; then
  echo 'Must specify $OSU_PATH_SGIMPT'
  exit 1
fi

module purge
module load mpi-sgi/mpt

cd $OSU_PATH_SGIMPT/libexec/osu-micro-benchmarks/mpi/pt2pt

mpiexec -np 48 -perhost 24 ./osu_mbw_mr > $LOG_DIR/mbw_mr.log

module purge