class_name ThermalModel
extends RefCounted
static func update(state:Dictionary,power_kw:float,afr:float,load:float,dt:float,cooling:float)->void:
 var lean:float=max(afr-14.2,0.0); var heat:float=power_kw*0.14+lean*2.0+load*2.0
 state.head_temp += (heat-(state.head_temp-SimulationConfig.AMBIENT_TEMP)*0.045*cooling)*dt
 state.oil_temp += (heat*0.22-(state.oil_temp-SimulationConfig.AMBIENT_TEMP)*0.018*cooling)*dt
 state.coolant_temp += (heat*0.18-(state.coolant_temp-SimulationConfig.AMBIENT_TEMP)*0.028*cooling)*dt
 state.egt = 420.0+power_kw*8.0+lean*45.0
