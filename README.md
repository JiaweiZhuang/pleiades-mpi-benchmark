[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3601526.svg)](https://doi.org/10.5281/zenodo.3601526)

MPI Benchmark on [NASA Pleiades](https://www.nas.nasa.gov/hecc/resources/pleiades.html)

To compare with https://github.com/JiaweiZhuang/aws-mpi-benchmark

## Build OSU

Load the recommended [SGI-MPT Library](https://www.nas.nasa.gov/hecc/support/kb/using-the-nas-recommended-mpt-library_305.html)

    module purge
    module load mpi-sgi/mpt
    which mpicc mpicxx mpiexec

The complete command to build OSU:

    mkdir $HOME/mpi-benchmark
    cd $HOME/mpi-benchmark
    wget http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-5.6.1.tar.gz
    tar zxf osu-micro-benchmarks-5.6.1.tar.gz
    rm osu-micro-benchmarks-5.6.1.tar.gz
    cd osu-micro-benchmarks-5.6.1

    echo 'export OSU_PATH_SGIMPT=$HOME/mpi-benchmark/osu_sgimpt' >> $HOME/.profile
    source $HOME/.profile

    module purge && module load mpi-sgi/mpt
    ./configure CC=mpicc CXX=mpicxx --prefix=$OSU_PATH_SGIMPT
    make
    make install

The variable `OSU_PATH_SGIMPT` will be used in run-time scripts.

## Run OSU

### Interactive

Can use the [devel squeue](https://www.nas.nasa.gov/hecc/support/kb/pleiades-devel-queue_290.html) for short development tests. Start interactive session via `qsub -I`:

    qsub -I -lselect=2:ncpus=24:mpiprocs=24:model=has,walltime=0:20:00 -q devel
    module load mpi-sgi/mpt

Specify rank-per-node via `-perhost`, similar to Slurm `--ntasks-per-node`. Otherwise, two ranks might start on the same node, which will test shared memory instead of interconnect.

    MPI_SHEPHERD=true mpiexec -np 2 -perhost 1 hostname

(print all run-time options via `mpiexec --help`)

Point-to-point latency and bandwidth:

    cd $OSU_PATH_SGIMPT/libexec/osu-micro-benchmarks/mpi/pt2pt/
    mpiexec -np 2 -perhost 1 ./osu_latency
    mpiexec -np 2 -perhost 1 ./osu_bw
    mpiexec -np 2 -perhost 1 ./osu_bibw

Set `export MPI_USE_TCP=true` to force TCP/IP interconnect instead of InfiniBand RDMA. (ref [HPE MPI user guide](https://support.hpe.com/hpsc/doc/public/display?docId=emr_na-a00037728en_us)). This will severely degrade MPI performance and should never be used for real model runs.

For multi-pair bandwidth, make sure that the first half of ranks are on one node:

    MPI_SHEPHERD=true mpiexec -np 48 -perhost 24 hostname
    mpiexec -np 48 -perhost 24 ./osu_mbw_mr

For collectives, see batch scripts below.

### Batch script

See [./scripts](./scripts)

    cd scripts/
    qsub run_pt2pt.pbs
    qsub run_pt2pt_multi.pbs
    qsub run_bcast.pbs
    qsub run_allreduce.pbs

## Reference

- https://www.nas.nasa.gov/hecc/support/kb/using-the-nas-recommended-mpt-library_305.html
- https://www.nas.nasa.gov/hecc/support/kb/preparing-to-run-on-pleiades-haswell-nodes_491.html
- https://www.nas.nasa.gov/hecc/support/kb/pleiades-devel-queue_290.html
- https://www.nas.nasa.gov/hecc/support/kb/pbs-environment-variables_178.html
- https://www.nas.nasa.gov/hecc/support/kb/default-variables-set-by-pbs_189.html
