class_name DamageModel
extends RefCounted
static func update(state:Dictionary,build:Dictionary,knock:float,mps:float,dt:float)->void:
 var safe_mps:float=float(build.material_limit)
 var stress:float=max(mps/safe_mps-0.85,0.0)+knock*1.7+max(state.head_temp-190.0,0.0)/35.0
 if not build.has_oil: stress+=4.0
 state.stress += stress*dt
 state.health=max(0.0,state.health-stress*0.055*dt)
 if state.health<=0.0: state.status="FAILED"; state.failure="CONNECTING ROD FAILURE"
 elif state.head_temp>225: state.status="OVERHEATING"
 elif knock>0.55: state.status="KNOCKING"
