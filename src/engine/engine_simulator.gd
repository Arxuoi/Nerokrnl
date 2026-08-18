class_name EngineSimulator
extends RefCounted
var build:Dictionary
var state:={"rpm":0.0,"status":"OFF","health":100.0,"head_temp":25.0,"oil_temp":25.0,"coolant_temp":25.0,"egt":25.0,"stress":0.0,"failure":"","running":false}
func _init(p_build:Dictionary): build=p_build
func start()->String:
 if not build.has_oil:return "WARNING: ENGINE HAS NO OIL"
 if not build.has_fuel:return "CRANKING — NO FUEL"
 if not build.has_ignition:return "CRANKING — NO SPARK"
 if float(build.clearance_cc)>35:return "CRANKING — INSUFFICIENT COMPRESSION"
 state.running=true;state.rpm=1400;state.status="IDLE";return "ENGINE STARTED"
func stop()->void: state.running=false;state.rpm=0;state.status="OFF"
func step(throttle:float,dt:float,target_rpm:float=-1.0)->Dictionary:
 if not state.running:return output(0,0,14.7,0,0)
 if state.status=="FAILED":return output(0,0,18,0,0)
 var idle:=1400.0; var desired:=target_rpm if target_rpm>0 else idle+throttle*(float(build.rev_limit)-idle)
 state.rpm=move_toward(state.rpm,desired,(3500.0+throttle*7000.0)*dt)
 if build.limiter!="none" and state.rpm>=build.rev_limit: state.rpm=build.rev_limit-150;state.status="LIMITER"
 else:state.status="IDLE" if state.rpm<1900 else "RUNNING"
 var ve:=AirflowModel.ve(build,state.rpm);var c:=CombustionModel.calculate(build,state.rpm,throttle,ve)
 var friction:=FrictionModel.loss_kw(build,state.rpm,state.oil_temp);var kw=max(0.0,(c.gross_kw-friction)*SimulationConfig.DRIVETRAIN_EFFICIENCY)
 var torque:=EngineMath.torque_from_kw(kw,state.rpm);var boost:float=float(build.boost_bar)*clamp((state.rpm-float(build.turbo_spool))/2500.0,0.0,1.0)
 var knock:=KnockModel.level(build,c.cr,c.afr,c.timing_error,state.head_temp,boost)
 ThermalModel.update(state,kw,c.afr,throttle,dt,float(build.cooling));DamageModel.update(state,build,knock,EngineMath.piston_speed(build.stroke,state.rpm),dt)
 return output(torque,EngineMath.hp_from_torque(torque,state.rpm),c.afr,ve,knock).merged({"air":c.air,"fuel":c.fuel,"friction":friction,"boost":boost})
func output(torque:float,hp:float,afr:float,ve:float,knock:float)->Dictionary:return {"rpm":state.rpm,"torque":torque,"hp":hp,"afr":afr,"ve":ve,"knock":knock,"head_temp":state.head_temp,"oil_temp":state.oil_temp,"coolant_temp":state.coolant_temp,"egt":state.egt,"health":state.health,"status":state.status}
