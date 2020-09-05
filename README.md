######   This Infra Project goal to is bring up some most common software infrastructure component (e.g. Postgres DB, Redis, Kafka, Nginx etc.) to up and running locally in just few seconds.
Checkout and execute the top level shell script to bring up and follow logs how to access it. Give it a try!!!!

- **common-vars.sh** file is where common variable names are defined for "infra" project. 
- Alias for Local Machine name can be given which would make entry in host file  (support for mac for now) and Infrastrucure component can be accessed by that name. e.g. Machine Alias is ***sachin-local-machine.com*** and once Nginx Is run, it would be available at https://sachin-local-machine.com/
- To run any software component locally, run respective folders' run file e.g. goto *run_nginx* folder and execute *run.sh* file to run nginx locally.
- Any component would produce the log for output. Look that for further details

    
