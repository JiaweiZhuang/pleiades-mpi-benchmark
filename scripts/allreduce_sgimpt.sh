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

cd $OSU_PATH_SGIMPT/libexec/osu-micro-benchmarks/mpi/collective
mpiexec ./osu_allreduce > $LOG_DIR/allreduce.log

module purge
