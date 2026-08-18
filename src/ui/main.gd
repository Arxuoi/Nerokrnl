extends Control
const BG=Color("101317");const PANEL=Color("191e24");const LINE=Color("303943");const TEXT=Color("e8edf2");const MUTED=Color("89939e");const CYAN=Color("34d3c8");const ORANGE=Color("ff9f43");const RED=Color("ff5364")
var build:=BuildData.default();var sim:=EngineSimulator.new(build);var vehicle:=VehicleSimulator.new();var page="MENU";var content:Control;var status:Label;var dyno_running=false;var dyno_rpm=1400.0;var dyno_data:Array=[];var throttle=0.0;var graph:Control;var live_labels={};var tutorial_step=0
func _ready():
 set_process(true);_theme();show_menu()
func _theme():
 var t=Theme.new();t.default_font_size=16
 var sb=StyleBoxFlat.new();sb.bg_color=PANEL;sb.border_color=LINE;sb.set_border_width_all(1);sb.corner_radius_top_left=5;sb.corner_radius_top_right=5;sb.corner_radius_bottom_left=5;sb.corner_radius_bottom_right=5;t.set_stylebox("normal","Button",sb)
 var hov=sb.duplicate();hov.bg_color=Color("28313a");hov.border_color=CYAN;t.set_stylebox("hover","Button",hov)
 var inp=sb.duplicate();inp.bg_color=Color("11161b");t.set_stylebox("normal","LineEdit",inp);theme=t
func clear():
 for c in get_children():c.queue_free()
 content=Control.new();content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(content);queue_redraw()
func _draw():draw_rect(Rect2(Vector2.ZERO,size),BG)
func label(txt:String,parent:Node,pos:Vector2,fs=16,color=TEXT)->Label:
 var l=Label.new();l.text=txt;l.position=pos;l.add_theme_font_size_override("font_size",fs);l.add_theme_color_override("font_color",color);parent.add_child(l);return l
func button(txt:String,parent:Node,pos:Vector2,call:Callable,w=210)->Button:
 var b=Button.new();b.text=txt;b.position=pos;b.size=Vector2(w,44);b.pressed.connect(call);parent.add_child(b);return b
func header(title:String,sub:String=""):
 label("MOTO / ENGINE LAB",content,Vector2(38,25),15,CYAN);label(title,content,Vector2(38,57),30);label(sub,content,Vector2(38,98),14,MUTED)
 status=label("READY",content,Vector2(980,34),15,CYAN)
func nav():
 var names=["MENU","ENGINE LAB","DYNO","ECU","TEST TRACK","SPECIFICATION"]
 for i in names.size():button(names[i],content,Vector2(38+i*198,650),func(): open_page(names[i]),180)
func show_menu():
 page="MENU";clear();label("MOTO",content,Vector2(68,52),72,TEXT);label("ENGINE LAB",content,Vector2(68,125),72,CYAN);label("PHYSICS-DRIVEN MOTORCYCLE ENGINE WORKSHOP",content,Vector2(73,214),15,MUTED)
 var items=["NEW BUILD","LOAD BUILD","ENGINE LAB","DYNO","TEST TRACK","SETTINGS","QUIT"]
 for i in items.size():button(items[i],content,Vector2(72,270+i*50),func():menu_action(items[i]),250)
 label("BUILD / TUNE / TEST / BREAK",content,Vector2(765,575),18,ORANGE);draw_engine(content,Vector2(800,220),1.4)
func menu_action(a:String):
 match a:
  "NEW BUILD":build=BuildData.default();sim=EngineSimulator.new(build);tutorial_step=1;show_workshop()
  "LOAD BUILD":var b=BuildData.load_file("user://autosave.melbuild");status_text("LOADED" if not b.is_empty() else "NO SAVE FOUND");if not b.is_empty():build=b;sim=EngineSimulator.new(build);show_workshop()
  "ENGINE LAB":show_workshop()
  "DYNO":show_dyno()
  "TEST TRACK":show_track()
  "SETTINGS":show_settings()
  "QUIT":get_tree().quit()
func open_page(p:String):
 match p:
  "MENU":show_menu()
  "ENGINE LAB":show_workshop()
  "DYNO":show_dyno()
  "ECU":show_ecu()
  "TEST TRACK":show_track()
  "SPECIFICATION":show_specs()
func status_text(s:String):if is_instance_valid(status):status.text=s
func panel(parent:Node,pos:Vector2,sz:Vector2)->Panel:
 var p=Panel.new();p.position=pos;p.size=sz;parent.add_child(p);return p
func field(parent:Node,title:String,key:String,pos:Vector2,suffix=""):
 label(title,parent,pos,13,MUTED);var e=LineEdit.new();e.text=str(build[key]);e.position=pos+Vector2(0,20);e.size=Vector2(150,36);e.text_submitted.connect(func(v):build[key]=float(v);sim.build=build;show_workshop());parent.add_child(e);label(suffix,parent,pos+Vector2(158,29),12,MUTED)
func show_workshop():
 page="ENGINE LAB";clear();header("ENGINE LAB","Configure geometry, breathing, fuel and structure — every choice changes the model.");nav()
 var p=panel(content,Vector2(38,130),Vector2(430,495));label("SHORT BLOCK",p,Vector2(20,14),15,CYAN)
 field(p,"BORE","bore",Vector2(20,50),"mm");field(p,"STROKE","stroke",Vector2(220,50),"mm");field(p,"CLEARANCE VOLUME","clearance_cc",Vector2(20,120),"cc");field(p,"ROD LENGTH","rod_length",Vector2(220,120),"mm")
 label("BREATHING + COMBUSTION",p,Vector2(20,190),15,CYAN);field(p,"INTAKE","intake_mm",Vector2(20,225),"mm");field(p,"INTAKE VALVE","intake_valve",Vector2(220,225),"mm");field(p,"HEADER","header_mm",Vector2(20,295),"mm");field(p,"CAM AGGRESSION","cam_aggression",Vector2(220,295))
 field(p,"OCTANE RON","octane",Vector2(20,365));field(p,"BOOST","boost_bar",Vector2(220,365),"bar")
 button("SAVE BUILD",p,Vector2(20,440),func():BuildData.save("user://autosave.melbuild",build);status_text("SAVED autosave.melbuild"),180);button("START ENGINE",p,Vector2(220,440),start_engine,180)
 draw_engine(content,Vector2(700,260),1.0);var cc=EngineMath.displacement(build.bore,build.stroke,build.cylinders);var cr=EngineMath.compression_ratio(cc,build.clearance_cc);label("%.1f cc"%cc,content,Vector2(650,470),34);label("CR %.2f:1  •  ROD RATIO %.2f"%[cr,build.rod_length/build.stroke],content,Vector2(650,515),16,MUTED)
 var errs=BuildData.validate(build);label("ASSEMBLY VALID" if errs.is_empty() else " / ".join(errs),content,Vector2(650,550),14,CYAN if errs.is_empty() else RED)
 if tutorial_step>0:label("TUTORIAL %d/8 — Set geometry, then START ENGINE."%tutorial_step,content,Vector2(650,590),14,ORANGE)
func draw_engine(parent:Node,origin:Vector2,scale:float):
 var d=EngineDiagram.new();d.position=origin;d.scale=Vector2.ONE*scale;parent.add_child(d)
func start_engine():status_text(sim.start());tutorial_step=min(tutorial_step+1,8)
func show_dyno():
 page="DYNO";clear();header("CHASSIS DYNO","Deterministic fixed-step sweep. Curves come directly from airflow and combustion.");nav();graph=DynoGraph.new();graph.position=Vector2(38,145);graph.size=Vector2(800,420);content.add_child(graph)
 var p=panel(content,Vector2(865,145),Vector2(375,420));var keys=["rpm","hp","torque","afr","head_temp","knock","health","status"]
 for i in keys.size():live_labels[keys[i]]=label(keys[i].to_upper()+"  —",p,Vector2(20,20+i*39),16,CYAN if i<3 else TEXT)
 button("START DYNO",p,Vector2(20,340),begin_dyno,155);button("EXPORT CSV",p,Vector2(190,340),export_csv,155)
func begin_dyno():
 if not sim.state.running:
  var msg=sim.start();if not sim.state.running:status_text(msg);return
 dyno_data=[];dyno_rpm=1400;dyno_running=true;status_text("DYNO RUNNING")
func _process(delta):
 if dyno_running:
  dyno_rpm+=1150.0*delta;var o=sim.step(1.0,delta,dyno_rpm);dyno_data.append({"time":Time.get_ticks_msec()/1000.0,"rpm":o.rpm,"torque":o.torque,"hp":o.hp,"afr":o.afr,"temperature":o.head_temp,"throttle":1.0,"knock":o.knock,"boost":o.get("boost",0)})
  if is_instance_valid(graph):graph.data=dyno_data;graph.queue_redraw();for k in live_labels:live_labels[k].text=k.to_upper()+"  "+format_value(o.get(k,"—"))
  if dyno_rpm>=build.rev_limit or o.status=="FAILED":dyno_running=false;status_text("DYNO COMPLETE" if o.status!="FAILED" else "CATASTROPHIC FAILURE")
 if page=="TEST TRACK" and sim.state.running:
  throttle=1.0 if Input.is_key_pressed(KEY_W) else 0.15;var o=sim.step(throttle,delta);var v=vehicle.step(o.torque,o.rpm,build,throttle,delta);update_track(o,v)
func format_value(v)->String:return "%.2f"%v if v is float else str(v)
func export_csv():
 var f=FileAccess.open("user://dyno_log.csv",FileAccess.WRITE);f.store_line("time,rpm,torque,horsepower,afr,temperature,throttle,knock,boost");for d in dyno_data:f.store_line("%s,%s,%s,%s,%s,%s,%s,%s,%s"%[d.time,d.rpm,d.torque,d.hp,d.afr,d.temperature,d.throttle,d.knock,d.boost]);status_text("EXPORTED dyno_log.csv")
func show_ecu():
 page="ECU";clear();header("ECU TUNING","Fuel, ignition, limiter, idle, launch and boost controls.");nav();var p=panel(content,Vector2(38,140),Vector2(1200,460));field(p,"FUEL CORRECTION","fuel_correction",Vector2(30,40));field(p,"BASE ADVANCE","timing_deg",Vector2(240,40),"°");field(p,"REV LIMIT","rev_limit",Vector2(450,40),"rpm");field(p,"BOOST TARGET","boost_bar",Vector2(660,40),"bar");field(p,"TURBO SPOOL","turbo_spool",Vector2(870,40),"rpm")
 label("RPM",p,Vector2(30,145),13,MUTED);for i in 6:label(str([1000,3000,5000,7000,9000,12000][i]),p,Vector2(160+i*155,145),13,MUTED)
 for row in 2:label("FUEL %" if row==0 else "IGN °",p,Vector2(30,200+row*75),14,CYAN);for i in 6:var e=LineEdit.new();e.text=str(build.fuel_correction*100 if row==0 else build.timing_deg);e.position=Vector2(150+i*155,190+row*75);e.size=Vector2(110,38);p.add_child(e)
 label("Launch control increases exhaust heat and mechanical stress while held.",p,Vector2(30,375),14,ORANGE)
func show_track():
 page="TEST TRACK";clear();header("TEST TRACK","W throttle • Q/E shift • C clutch. Torque, gearing, traction and drag are simulated.");nav();var road=TrackView.new();road.name="Road";road.position=Vector2(38,160);road.size=Vector2(1200,300);content.add_child(road);live_labels.clear();for i in 4:var k=["speed","distance","gear","rpm"][i];live_labels[k]=label(k.to_upper()+" —",content,Vector2(70+i*285,500),20,CYAN);button("START / RESET",content,Vector2(990,550),func():vehicle=VehicleSimulator.new();sim=EngineSimulator.new(build);status_text(sim.start()),200)
func update_track(o:Dictionary,v:Dictionary):
 for k in live_labels:live_labels[k].text=k.to_upper()+"  "+format_value(o.get(k,v.get(k,0)));var road=content.get_node_or_null("Road");if road:road.speed=v.speed;road.wheelspin=v.wheelspin;road.queue_redraw()
func show_specs():
 page="SPECIFICATION";clear();header("ENGINE SPECIFICATION","Calculated build sheet and mechanical limits.");nav();var cc=EngineMath.displacement(build.bore,build.stroke,build.cylinders);var rows={"Displacement":"%.2f cc"%cc,"Bore × Stroke":"%.1f × %.1f mm"%[build.bore,build.stroke],"Architecture":"OVERSQUARE" if build.bore/build.stroke>1.04 else ("UNDERSQUARE" if build.bore/build.stroke<0.96 else "SQUARE"),"Compression ratio":"%.2f : 1"%EngineMath.compression_ratio(cc,build.clearance_cc),"Rod ratio":"%.2f"%(build.rod_length/build.stroke),"Mean piston speed @ limit":"%.2f m/s"%EngineMath.piston_speed(build.stroke,build.rev_limit),"Safe mechanical speed":"%.1f m/s"%build.material_limit,"Fuel":"RON %d"%int(build.octane),"Reliability":"%.1f %%"%sim.state.health,"Engine state":sim.state.status}
 var i=0;for k in rows:label(k,content,Vector2(100,150+i*42),15,MUTED);label(rows[k],content,Vector2(500,150+i*42),17,TEXT);i+=1
 button("EXPORT BUILD",content,Vector2(900,180),func():BuildData.save("user://shared_build.melbuild",build);status_text("EXPORTED shared_build.melbuild"));button("IMPORT BUILD",content,Vector2(900,240),func():var b=BuildData.load_file("user://shared_build.melbuild");if BuildData.validate(b).is_empty() and not b.is_empty():build=b;sim=EngineSimulator.new(build);show_specs())
func show_settings():clear();header("SETTINGS","Difficulty changes assistance and wear rate.");nav();for i in 3:var mode=["Arcade","Simulation","Engineer"][i];button(mode,content,Vector2(100,180+i*70),func():build.difficulty=mode;status_text(mode.to_upper()+" MODE"),300)
func _input(e):
 if page=="TEST TRACK" and e is InputEventKey and e.pressed:
  if e.keycode==KEY_E:vehicle.gear=min(vehicle.gear+1,build.gears.size())
  if e.keycode==KEY_Q:vehicle.gear=max(vehicle.gear-1,1)
class EngineDiagram extends Control:
 func _draw():
  draw_rect(Rect2(-60,100,320,145),Color("202831"));draw_rect(Rect2(10,-20,180,130),Color("29343e"));draw_circle(Vector2(100,175),64,Color("11161b"));draw_circle(Vector2(100,175),25,CYAN);draw_line(Vector2(100,150),Vector2(100,58),Color("c7d0d8"),18);draw_circle(Vector2(100,42),38,ORANGE);draw_rect(Rect2(-105,2,110,55),Color("29343e"));draw_line(Vector2(-100,28),Vector2(-175,5),CYAN,14);draw_line(Vector2(190,36),Vector2(305,72),ORANGE,18);draw_string(ThemeDB.fallback_font,Vector2(-70,280),"MODULAR SINGLE CYLINDER",HORIZONTAL_ALIGNMENT_LEFT,300,15,MUTED)
class DynoGraph extends Control:
 var data:Array=[]
 func _draw():
  draw_rect(Rect2(Vector2.ZERO,size),Color("11161b"));for i in 6:var y=i*size.y/5;draw_line(Vector2(0,y),Vector2(size.x,y),LINE,1)
  for i in 9:var x=i*size.x/8;draw_line(Vector2(x,0),Vector2(x,size.y),LINE,1)
  if data.size()>1:
   var hp=PackedVector2Array();var tq=PackedVector2Array();var maxrpm=max(12000.0,float(data[-1].rpm));for d in data:hp.append(Vector2(d.rpm/maxrpm*size.x,size.y-d.hp/80.0*size.y));tq.append(Vector2(d.rpm/maxrpm*size.x,size.y-d.torque/100.0*size.y));draw_polyline(hp,CYAN,3);draw_polyline(tq,ORANGE,3)
  draw_string(ThemeDB.fallback_font,Vector2(20,28),"HP",HORIZONTAL_ALIGNMENT_LEFT,-1,15,CYAN);draw_string(ThemeDB.fallback_font,Vector2(70,28),"TORQUE",HORIZONTAL_ALIGNMENT_LEFT,-1,15,ORANGE)
class TrackView extends Control:
 var speed=0.0;var wheelspin=false
 func _draw():
  draw_rect(Rect2(Vector2.ZERO,size),Color("151b21"));draw_rect(Rect2(0,210,size.x,90),Color("252d34"));for i in 12:var x=fmod(i*130-speed*2,1400.0);draw_rect(Rect2(x,250,70,5),MUTED)
  draw_circle(Vector2(330,210),34,Color("090b0d"));draw_circle(Vector2(500,210),34,Color("090b0d"));draw_line(Vector2(330,190),Vector2(420,135),CYAN,13);draw_line(Vector2(420,135),Vector2(500,190),CYAN,13);draw_line(Vector2(330,190),Vector2(500,190),CYAN,10);draw_circle(Vector2(430,115),18,ORANGE);if wheelspin:draw_string(ThemeDB.fallback_font,Vector2(285,275),"WHEELSPIN",HORIZONTAL_ALIGNMENT_LEFT,-1,15,RED)
