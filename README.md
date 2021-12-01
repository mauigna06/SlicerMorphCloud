# SlicerMorphCloud
Docker for running SlicerMorph on Cloud

## Instructions
While the container supports Nvidia drivers and GPU, this example for launching the containers from a non-GPU VM instance. 

1. Inside the SlicerMorphCloud folder build the contained :

```sudo docker build -t cloud .```

2. Create a users file that contains usernames in each line. 
3. Create persistent storage points for shared data and user space and modify the **nogpu.sh** accordingly. (Note the /temp folder location)
4. start a container for each user using the command

```for user in $(cat users); do ./nogpu.sh $user ; done > instance-table.csv```

this will generate a table of containers tied to users name, URL to be accessed and the password to be used. 

5. Follow the instructions that appear on the terminal
