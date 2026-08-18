class_name CombustionModel
extends RefCounted
static func calculate(build:Dictionary,rpm:float,throttle:float,ve:float)->Dictionary:
 var air:=AirflowModel.air_mass_per_second(build,rpm,throttle,ve)
 var target:=14.2 if throttle<0.35 else 12.9
 var afr:float=target/float(build.fuel_correction)
 var fuel:float=air/max(afr,1.0)
 var afr_eff:float=clamp(1.0-0.055*pow(afr-12.8,2.0),0.35,1.0)
 var cr:float=EngineMath.compression_ratio(EngineMath.displacement(build.bore,build.stroke,build.cylinders),build.clearance_cc)
 var ideal_advance:=12.0+rpm/500.0
 var timing_error:float=float(build.timing_deg)-ideal_advance
 var timing_eff:float=clamp(1.0-0.0025*pow(timing_error,2.0),0.65,1.0)
 var thermal:float=clamp(0.20+(cr-7.0)*0.012,0.18,0.34)*afr_eff*timing_eff
 var gross_kw:float=fuel*SimulationConfig.FUEL_LHV*thermal/1000.0
 return {"air":air,"fuel":fuel,"afr":afr,"gross_kw":gross_kw,"cr":cr,"timing_error":timing_error}
