# devtools::install_github('qBioTurin/epimod', ref='master',dependencies=TRUE)

library(epimod)

model.generation(net_fname = "Net/HPCmodel.PNPRO")
system("mv ./HPCmodel.* ./Net")


paramsName = c("Change_gpu_mpi" ,"Change_gpu_other","Change_gpu_io",
               "Change_mpi_gpu","Change_mpi_other","Change_mpi_io",
               "Change_other_gpu","Change_other_mpi","Change_other_io",
               "Change_io_gpu","Change_io_mpi","Change_io_other",
               "Change_gpu_gpu","Change_mpi_mpi","Change_io_io","Change_other_other")
params = rep(0,length(paramsName) )
names(params) = paramsName

# from OTHER to ...
params[grep(x = paramsName,pattern = "_other_")] = 0.1
# from ... to OTHER
params[grep(x = paramsName,pattern = "_other$")] = 0.5
# from ... to GPU
params[grep(x = paramsName,pattern = "_gpu$")] = 0.3
# from GPU to ...
params[grep(x = paramsName,pattern = "_gpu_")] = 0.1

model.analysis(solver_fname = "./Net/HPCmodel.solver",
               parameters_fname = "Input/parametersList.csv",
               functions_fname = "./RFunction/Functions.R",
               f_time = 50,
               s_time = 1,
               i_time = 0,
               n_run = 100,
               solver_type = "SSA",
               parallel_processors = 5,
               ini_v = params) #debug = T )



### Calibration 

model.calibration(solver_fname = "./Net/HPCmodel.solver",
                  parameters_fname = "Input/parametersList.csv",
                  functions_fname = "./RFunction/Functions.R",
                  reference_data = "./Input/ReferenceCl2.csv",
                  distance_measure = "error",
                  parallel_processors = 10,
                  f_time = 5*60, # simulo 5 minuti
                  s_time = 1,
                  i_time = 0,
                  n_run = 500,
                  lb_v = rep(0,length(paramsName)),
                  ub_v = rep(1,length(paramsName)),
                  ini_v = rep(0.5,length(paramsName)),
                  solver_type = "SSA"
                  ) #debug = T )

