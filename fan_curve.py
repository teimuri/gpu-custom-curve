import numpy as np
import argparse
############# Define your own curve data#########
curve_data=[
    {'cruve':[[60,60],[70,83],[80,85],[100,87]],'fan_id':0,'gpu_id':1,'min_speed':22,},
    {'cruve':[[40,60],[60,65],[80,69],[100,71]],'fan_id':1,'gpu_id':0,'max_speed':85},
    {'cruve':[[40,60],[60,65],[80,69],[100,71]],'fan_id':2,'gpu_id':0,'max_speed':85},
]
#################################################
def point_extractor(point,curve_list,x2y=1):
    if (curve_list[:,x2y]==point).any():
        return curve_list[:,1-x2y][curve_list[:,x2y]==point][0]
    else:
        lower_bound_temp_id=(curve_list[:,x2y]<point).sum()
        
        lower_bound_x=curve_list[lower_bound_temp_id-1,x2y]
        upper_bound_x=curve_list[lower_bound_temp_id,x2y]

        lower_bound_y=curve_list[lower_bound_temp_id-1,1-x2y]
        upper_bound_y=curve_list[lower_bound_temp_id,1-x2y]

        relative_dist=(point-lower_bound_x)/(upper_bound_x-lower_bound_x)
        target= (upper_bound_y-lower_bound_y)*relative_dist+lower_bound_y
        return target


# Create an argument parser
parser = argparse.ArgumentParser()

# Define arguments
parser.add_argument('--temp',type=int, help='First argument')
parser.add_argument('--speed',type=int, help='Second argument')
parser.add_argument('--gpu_id',type=int, help='Second argument')
# Parse the command-line arguments
args = parser.parse_args()

# Access the arguments
current_temp = args.temp
current_speed = args.speed
gpu_id = args.gpu_id

for curve_dict in curve_data:
    if gpu_id==curve_dict['gpu_id']:
        curve = np.array(curve_dict['cruve'])
        fan_id=curve_dict['fan_id']

        #To prevent from error in the event of high temperture
        overflowtemp=curve[-1,1]+100
        curve = np.concatenate((curve,[[100,overflowtemp]]),axis=0)
        
        lower_bound_temp_id = np.searchsorted(curve[:,1], current_temp)
        lower_bound_temp=curve[lower_bound_temp_id-1,1]
        upper_bound_temp=curve[lower_bound_temp_id,1]

        lower_bound_fan=curve[lower_bound_temp_id-1,0]
        upper_bound_fan=curve[lower_bound_temp_id,0]
        
        if current_temp>=curve[0,1] or (current_speed!=curve_dict.get('min_speed',0) and current_temp>(curve[0,1]-10)):
            # print(33)
            curve_temp=point_extractor(current_speed,curve,x2y=0)
            # print(curve_temp)
            if curve_temp<current_temp:
                target_speed=point_extractor(current_temp,curve)
            elif current_temp<curve_temp-5:
                curve[:,1]-=5
                target_speed=point_extractor(current_temp,curve)
            else:
                target_speed=current_speed

        else:
            
            target_speed=curve_dict.get('min_speed',0)
                
            
        target_speed=min(target_speed,curve_dict.get('max_speed',100))
        target_speed=max(target_speed,curve_dict.get('min_speed',0))
        print(int(target_speed))
        print(int(fan_id))
        


