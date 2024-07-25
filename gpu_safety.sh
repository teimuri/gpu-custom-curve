#!/bin/bash

end_time=58
time_passed=0
gpu_id=0
working_dir=<path_to_working_dir> # replace with your working directory
while [ $time_passed -lt $end_time ]; do

    temp=$(nvidia-smi -i $gpu_id --query-gpu=temperature.gpu --format=csv,noheader,nounits)
    echo $temp >> $working_dir/temps.txt
    if [ "$temp" -gt 75 ]; 
    then
    	sudo nvidia-smi -i $gpu_id -pl 150
    	sleep 50
    	temp=$(nvidia-smi -i $gpu_id --query-gpu=temperature.gpu --format=csv,noheader,nounits)
    	if [ "$temp" -gt 75 ];
    	then
        	sudo reboot
        	# echo 1
        else
        	time_passed=70
        fi
    else
    	if [ "$temp" -lt 76 ];
    	then
    		power_limit=$(nvidia-smi -i $gpu_id --query-gpu=power.limit --format=csv,noheader,nounits | cut -d '.' -f 1)
    		echo $temp
	    	if [ "$temp" -gt 70 ];
	    	then
	    		new_power_limit=$(($power_limit - 20))

	    		if [ "$new_power_limit" -gt 149 ];
	    		then
	    			sudo nvidia-smi -i $gpu_id -pl $new_power_limit
	    		fi
	    	 else
	    	 	if [ "$temp" -lt 69 ];
	    	 	then
		    	 	new_power_limit=$(($power_limit + 5))
		    	 	echo $new_power_limit
		    	 	if [ "$new_power_limit" -lt 301 ];
		    		then
		    			sudo nvidia-smi -i $gpu_id -pl $new_power_limit
		    		else
		    			if [ "$power_limit" -ne 300 ];
		    			then
		    				sudo nvidia-smi -i $gpu_id -pl 300
		    			fi
		    		fi
		    	fi
	    	fi
    	
        else
            sudo reboot
			# echo 1
        fi
        
    fi
    sleep 10
    time_passed=$((time_passed+10))
    
done

