class_name VehicleSimulator
extends RefCounted
var speed:=0.0;var distance:=0.0;var gear:=1
func step(engine_torque:float,rpm:float,build:Dictionary,throttle:float,dt:float)->Dictionary:
 var ratio:float=build.gears[gear-1]*build.final_drive;var clutch:=ClutchModel.transfer(engine_torque,build.clutch_capacity)
 var wheel_force:float=clutch.torque*ratio*0.91/(build.wheel_diameter/2.0);var drag:float=0.5*1.184*build.cd*build.frontal_area*speed*speed
 var traction:float=build.vehicle_weight*9.81*0.75;var wheelspin:bool=wheel_force>traction
 var accel:float=(min(wheel_force,traction)-drag)/build.vehicle_weight;speed=max(0.0,speed+accel*dt);distance+=speed*dt
 return {"speed":speed*3.6,"distance":distance,"gear":gear,"wheelspin":wheelspin,"clutch_slip":clutch.slip,"wheelie":wheel_force*(build.wheelbase*0.55)>build.vehicle_weight*9.81*build.wheelbase*0.45}
