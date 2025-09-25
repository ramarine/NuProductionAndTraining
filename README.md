This is a collection of scripts which I use to create atmospheric neutrinos using the DUNE LArSoft suite. To be able to use this you need to have LArSoft installed on your machine. 
The three main scripts which will run everything in the background are:

run_all_e_CC.sh

run_all_mu_CC.sh

run_all_tau_CC.sh 


What is special about these scripts is that the logs are saved directly in the data/logs/ folder, with specific names such that one can debug easier in case of errors. Also, in the same log directory there is the job_times.log where one can see the time per job and the maximum memory used! Very useful to better predict times for future jobs. 

