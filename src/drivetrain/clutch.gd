class_name ClutchModel
extends RefCounted
static func transfer(torque:float,capacity:float)->Dictionary:return {"torque":min(torque,capacity),"slip":max(torque-capacity,0.0)/max(torque,1.0)}
