class_name FrictionModel
extends RefCounted
static func loss_kw(build:Dictionary,rpm:float,oil_temp:float)->float:
 var mps:float=EngineMath.piston_speed(build.stroke,rpm); var viscosity:float=clamp(1.0+abs(oil_temp-95.0)/180.0,1.0,1.7)
 return (0.22+0.000000018*rpm*rpm*EngineMath.displacement(build.bore,build.stroke,build.cylinders)+0.015*mps*mps)*viscosity
