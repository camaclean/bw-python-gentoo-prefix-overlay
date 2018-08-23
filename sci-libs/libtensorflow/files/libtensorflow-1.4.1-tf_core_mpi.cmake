
add_library(tf_core_mpi STATIC
    "${tensorflow_source_dir}/tensorflow/contrib/mpi/mpi_utils.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/mpi/mpi_server_lib.cc"
    "${tensorflow_source_dir}/tensorflow/contrib/mpi/mpi_rendezvous_mgr.cc"
)

