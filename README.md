This is a collection of scripts which I use to create atmospheric neutrinos using the DUNE LArSoft suite. 
The three main scripts are run_all_tau/mu/e_CC.sh. To be able to use this you need to have LArSoft installed on your machine. 

What is special about these scripts is that the logs are saved directly in the data/logs/ folder, with specific names such that one can debug easier in case of errors. Also, in the same log there is the job_times.log where one can see the time per job and the maximum memory used! Very useful to better predict times for future jobs. 

