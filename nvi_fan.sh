#!/bin/bash
end_time=56
time_passed=0
working_dir=<path_to_working_dir> # replace with your working directory
XAUTHORITY=/run/user/126/gdm/Xauthority # replace with your Xauthority file
numberOfgpu=$(nvidia-smi --query-gpu=index --format=csv,noheader | wc -l)
while [ $time_passed -lt $end_time ]; do
    for((gpu_id=0; gpu_id<numberOfgpu; gpu_id++))
    do

    # Execute the first command and capture its output
        temp=$(nvidia-smi -i $gpu_id --query-gpu=temperature.gpu --format=csv,noheader,nounits)

    # Execute the second command and capture its output
        speed=$(nvidia-smi -i $gpu_id --query-gpu=fan.speed --format=csv,noheader,nounits)

    # Pass the outputs as arguments to the Python script and capture its output
        python_output=$(python3 $working_dir/fan_curve.py --temp $temp --speed $speed --gpu_id $gpu_id)
        IFS=$'\n' read -r -d '' -a lines <<< "$python_output"

        # Loop through the array and print pairs
        for ((i=0; i<${#lines[@]}; i+=2)); do
            target_speed=${lines[i]}
            fan_id=${lines[i+1]}
            if [ "$target_speed" -ne "$speed" ]
            then
                sudo DISPLAY=:0 XAUTHORITY=$XAUTHORITY nvidia-settings -a [fan:$fan_id]/GPUTargetFanSpeed=$target_speed
            fi
        done

    done
    sleep 4
    
    time_passed=$((time_passed+4))
    
done
