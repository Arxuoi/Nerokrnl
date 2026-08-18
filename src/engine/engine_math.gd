class_name EngineMath
extends RefCounted
static func displacement(bore_mm: float, stroke_mm: float, cylinders: int=1) -> float: return PI/4.0*bore_mm*bore_mm*stroke_mm*cylinders/1000.0
static func compression_ratio(swept_cc: float, clearance_cc: float) -> float: return (swept_cc+clearance_cc)/max(clearance_cc,0.001)
static func piston_speed(stroke_mm: float,rpm: float)->float: return 2.0*stroke_mm/1000.0*rpm/60.0
static func hp_from_torque(torque_nm:float,rpm:float)->float: return torque_nm*rpm/7127.0
static func torque_from_kw(kw:float,rpm:float)->float: return kw*9549.0/max(rpm,1.0)
