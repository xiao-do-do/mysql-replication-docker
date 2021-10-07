#!/bin/bash

docker cp ./master.sh mysql:/master.sh 
docker exec -it mysql /bin/bash -c "cd / | chmod +x master.sh | ./master.sh"

