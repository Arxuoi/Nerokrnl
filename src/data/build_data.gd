class_name BuildData
extends RefCounted
static func default()->Dictionary:return {"engine_name":"150 Street Lab","bore":57.3,"stroke":57.8,"cylinders":1,"cycle":4,"clearance_cc":17.0,"rod_length":105.0,"intake_mm":28.0,"intake_valve":26.0,"header_mm":28.0,"cam_peak":7500.0,"cam_width":4200.0,"cam_aggression":0.08,"fuel_correction":1.0,"timing_deg":24.0,"octane":95,"boost_bar":0.0,"turbo_spool":5500.0,"rev_limit":10500.0,"limiter":"soft","material_limit":24.0,"cooling":1.2,"has_oil":true,"has_fuel":true,"has_ignition":true,"gears":[2.8,1.9,1.45,1.15,0.95,0.8],"final_drive":3.1,"clutch_capacity":28.0,"wheel_diameter":0.56,"vehicle_weight":142.0,"cd":0.62,"frontal_area":0.55,"wheelbase":1.34,"difficulty":"Simulation"}
static func validate(b:Dictionary)->Array[String]:
 var e:Array[String]=[]
 if b.bore>72:e.append("CYLINDER WALL TOO THIN")
 if b.stroke>75:e.append("PISTON / CRANKCASE INTERFERENCE")
 if b.clearance_cc<=0:e.append("INVALID CLEARANCE VOLUME")
 if b.intake_valve>b.bore*0.55:e.append("PISTON TO VALVE CLEARANCE DANGEROUS")
 return e
static func save(path:String,b:Dictionary)->Error:
 var f:=FileAccess.open(path,FileAccess.WRITE);if f==null:return FileAccess.get_open_error()
 f.store_string(JSON.stringify(b,"  "));return OK
static func load_file(path:String)->Dictionary:
 if not FileAccess.file_exists(path):return {}
 var v=JSON.parse_string(FileAccess.get_file_as_string(path));return v if v is Dictionary else {}
