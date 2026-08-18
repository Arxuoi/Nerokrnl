class_name Gearbox
extends RefCounted
static func speed_kph(rpm:float,ratio:float,final_drive:float,wheel_diameter_m:float)->float:return rpm/(ratio*final_drive)*PI*wheel_diameter_m*60.0/1000.0
static func rpm_after_shift(rpm:float,old_ratio:float,new_ratio:float)->float:return rpm*new_ratio/old_ratio
