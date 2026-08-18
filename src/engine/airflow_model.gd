class_name AirflowModel
extends RefCounted
static func ve(build: Dictionary, rpm: float) -> float:
 var cam_peak: float = float(build.get("cam_peak", 7500.0)); var width: float = float(build.get("cam_width", 4200.0))
 var resonance: float = exp(-pow((rpm-cam_peak)/width,2.0))
 var cc: float = EngineMath.displacement(build.bore,build.stroke,build.cylinders)
 var ideal_intake: float = 0.78 * sqrt(cc)
 var intake_ratio: float = float(build.intake_mm)/max(ideal_intake,1.0)
 var size_match: float = clamp(1.0-0.24*abs(intake_ratio-1.0),0.65,1.03)
 var valve_limit: float = clamp(float(build.intake_valve)*float(build.intake_valve)/(cc*3.8),0.65,1.05)
 var exhaust_match: float = clamp(1.0-abs(float(build.header_mm)-ideal_intake*0.85)/80.0,0.72,1.05)
 var cam_gain: float = float(build.cam_aggression)*resonance
 var boost: float = 1.0 + float(build.boost_bar)*clamp((rpm-float(build.turbo_spool))/2500.0,0.0,1.0)
 if int(build.cycle)==2:
  var pipe_peak: float=float(build.get("pipe_peak",8500)); resonance=exp(-pow((rpm-pipe_peak)/1800.0,2.0)); cam_gain=0.32*resonance-0.12
 return clamp((0.68+0.18*resonance+cam_gain)*size_match*valve_limit*exhaust_match*boost,0.35,1.35)
static func air_mass_per_second(build: Dictionary, rpm: float, throttle: float, volumetric_efficiency: float) -> float:
 var cycles := 1.0 if int(build.cycle)==2 else 2.0
 return EngineMath.displacement(build.bore,build.stroke,build.cylinders)/1000000.0 * rpm/60.0/cycles * volumetric_efficiency * SimulationConfig.AIR_DENSITY * (0.15+0.85*throttle)
