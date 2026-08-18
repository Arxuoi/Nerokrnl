extends SceneTree
var failures=0
func check(name:String,actual:float,expected:float,tol:float=0.01):
 if abs(actual-expected)>tol:printerr("FAIL ",name," got ",actual," expected ",expected);failures+=1
 else:print("PASS ",name)
func _init():
 check("63x67 displacement",EngineMath.displacement(63,67,1),208.86,0.02)
 check("compression ratio",EngineMath.compression_ratio(100,10),11,0.001)
 check("piston speed",EngineMath.piston_speed(60,10000),20,0.001)
 check("torque power",EngineMath.hp_from_torque(71.27,1000),10,0.01)
 check("gear speed",Gearbox.speed_kph(6000,2,3,0.6),113.097,0.01)
 var b=BuildData.default();var c=CombustionModel.calculate(b,6000,1,0.85);check("AFR",c.afr,12.9,0.01)
 b.bore=80;if BuildData.validate(b).is_empty():printerr("FAIL compatibility");failures+=1
 var path="user://test.melbuild";BuildData.save(path,BuildData.default());var loaded=BuildData.load_file(path);check("save/load",loaded.bore,57.3,0.001)
 print("TESTS COMPLETE failures=",failures);quit(failures)
