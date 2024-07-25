The purpose of this project is to be able to set custom fan curve for all the GPUs on linux server.
This code as only been test on Ubuntu 20.04
<span style="color:red">Caution:</span> Using this code comes with some degree of danger for your GPU, and in the case of an extremely unlikely catastrophic failure, you might burn out your GPU. Even though I haven't encountered any problems, I can't guarantee that you won't.

# How to Use

First visit this websit to find the location to you XAUTHORITY file.
https://u2pia.medium.com/ubuntu-20-04-nvidia-gpu-control-through-ssh-terminal-bb136f447e11

1. Now execute this command. If you have more than one GPU repeate it while increasing the value for `gpu:0`. 
```
sudo DISPLAY=:0 XAUTHORITY=/run/user/126/gdm/Xauthority nvidia-settings -a [gpu:0]/GPUFanControlState=1
```
Important note: You also have to execute it every time the system is reseted.

1. After finding it's address go ahead and clone this repository:
```
git clone https://github.com/teimuri/gpu-custom-curve.git
cd gpu-custom-curve
```
1. Open nvi_fan.sh and replace <path_to_working_dir> with your working directory. Also change the value of XAUTHORITY if it differs for you.

1. Also replace the <path_to_working_dir> in the gpu_safety.sh.

1. Now open fan_curve.py and change the curve_data to your liking and adjust to the number of GPUs you have. Each sublist of a `'cruve'` value has the template of of `[<fan_speed>,<temperature>]`. For the `fan_id` and `gpu_id` you have to figure out the mapping. Each gpu have some fans assigne to it and they can be accessed through an id for each fan. The id is an integer. You can figure it by mannully changing the fan speed and checking which id effects which fans. Use this command to figure out the mapping:
```
sudo DISPLAY=:0 XAUTHORITY=<XAUTHORITY_path> nvidia-settings -a [fan:<fan_id>]/GPUTargetFanSpeed=100
```
1. So now you know the mapping of fan_id to your GPUs. You should also run this command to find the Id for each of your GPU:
```
nvidia-smi --query-gpu=index,name,temperature.gpu --format=csv
```

1. Now run the nvi_fan.sh file as bash file to check if it works as desired. If it works as desired you can add it as a crone job with an interval of one minute. But before that please read the next step.

1. I strongly recommend using gpu_safety.sh as well, as it will protect your GPU in case of any failures during the fan curve process. However, since it may restart your system in case of danger, I advise you to read and understand it before use. It also adjusts the GPU power, but this depends heavily on the GPU model, so it's even more important to understand it before use.

1. To use gpu_safety.sh, assign it to a cronjob with an interval of 1 minute.