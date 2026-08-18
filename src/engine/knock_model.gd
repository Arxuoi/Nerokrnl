class_name KnockModel
extends RefCounted
static func level(build:Dictionary,cr:float,afr:float,timing_error:float,head_temp:float,boost:float)->float:
 var required:float=87.0+(cr-8.0)*2.5+boost*10.0+max(timing_error,0.0)*0.35+max(head_temp-150.0,0.0)*0.04
 return clamp((required-float(build.octane))/12.0 + max(afr-14.5,0.0)*0.12,0.0,1.0)
