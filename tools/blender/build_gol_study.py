"""Original, reference-guided two-door hatch study. No purchased/external meshes.
Run: blender --background --python tools/blender/build_gol_study.py
Coordinates in modelling helpers are Godot X/right, Y/up, -Z/front, metres.
"""
import bpy
import math
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'assets/vehicles/gol_study'
OUT.mkdir(parents=True, exist_ok=True)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)
for datablock in list(bpy.data.materials):
    bpy.data.materials.remove(datablock)

def V(p): return (p[0], -p[2], p[1])
def mat(name, color, metal=0, rough=.5, alpha=1):
    m=bpy.data.materials.new(name); m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value=(*color,alpha)
    p.inputs['Metallic'].default_value=metal
    p.inputs['Roughness'].default_value=rough
    p.inputs['Alpha'].default_value=alpha
    m.diffuse_color=(*color,alpha)
    return m
paint=mat('Paint',(.48,.52,.55),.65,.25)
glass=mat('Glass',(.07,.12,.14),.15,.1,.30)
interior=mat('InteriorColor',(.05,.06,.07),0,.85)
seat=mat('SeatColor',(.07,.08,.09),0,.9)
seat_trim=mat('SeatTrim',(.03,.04,.05),0,.85)
black=mat('RubberTrim',(.012,.015,.019),0,.72)
chrome=mat('Chrome',(.68,.72,.77),.9,.17)
reflector=mat('LampReflector',(.60,.64,.68),.55,.22)
lens=mat('LampLens',(.48,.58,.63),.10,.12,.20)
red=mat('RedLens',(.42,.008,.014),.15,.23)
amber=mat('AmberLens',(.60,.17,.014),.10,.28)
white=mat('ReverseLens',(.45,.48,.50),.15,.22)
instrument=mat('InstrumentBlack',(.007,.01,.012),0,.45)
mirror=mat('Mirror',(.75,.80,.84),1,.07)

# Group origins match the existing animation adapters.
def empty(name, position=(0,0,0)):
    obj=bpy.data.objects.new(name,None); bpy.context.collection.objects.link(obj)
    obj.location=V(position); return obj
body=empty('Body'); fixedglass=empty('Glass'); cabin=empty('Interior')
left=empty('LeftDoor',(-.82,.57,-.66)); right=empty('RightDoor',(.82,.57,-.66))
hood=empty('Hood',(0,1.055,-.73)); hatch=empty('Hatch',(0,1.54,1.12))

def mesh(name, vertices, faces, material, parent, smooth=True, solid=0, bevel=0):
    data=bpy.data.meshes.new(name); data.from_pydata([V(v) for v in vertices],[],faces); data.update()
    obj=bpy.data.objects.new(name,data); bpy.context.collection.objects.link(obj); obj.parent=parent
    obj.data.materials.append(material)
    # Recalculate normals on closed parts; open panels are oriented explicitly below.
    if smooth:
        for p in data.polygons: p.use_smooth=True
    if solid:
        mod=obj.modifiers.new('PanelThickness','SOLIDIFY'); mod.thickness=solid; mod.offset=-1
    if bevel:
        mod=obj.modifiers.new('RoundedEdges','BEVEL'); mod.width=bevel; mod.segments=3
        mod=obj.modifiers.new('WeightedNormals','WEIGHTED_NORMAL'); mod.keep_sharp=True; mod.weight=50
    return obj

def cube(name,size,at,material,parent,bevel=.02):
    x,y,z=[v/2 for v in size]
    verts=[(at[0]+sx*x,at[1]+sy*y,at[2]+sz*z) for sx,sy,sz in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]]
    faces=[(0,3,2,1),(4,5,6,7),(0,4,7,3),(1,2,6,5),(0,1,5,4),(3,7,6,2)]
    return mesh(name,verts,faces,material,parent,True,bevel=min(bevel,min(size)*.45))

def tube(name,points,radius,material,parent,sides=10):
    verts=[]; faces=[]
    for i,p in enumerate(points):
        tangent=Vector(points[min(i+1,len(points)-1)])-Vector(points[max(0,i-1)])
        tangent.normalize(); ref=Vector((0,1,0))
        if abs(tangent.dot(ref))>.95: ref=Vector((1,0,0))
        a=tangent.cross(ref).normalized(); b=tangent.cross(a).normalized()
        for k in range(sides):
            v=Vector(p)+radius*(math.cos(k*math.tau/sides)*a+math.sin(k*math.tau/sides)*b)
            verts.append(tuple(v))
    for j in range(len(points)-1):
        for k in range(sides):
            a=j*sides+k; b=j*sides+(k+1)%sides
            faces.append((a,b,b+sides,a+sides))
    faces.extend([tuple(reversed(range(sides))),tuple((len(points)-1)*sides+k for k in range(sides))])
    return mesh(name,verts,faces,material,parent)

def sheet_rail(name,points,width,depth,material,parent):
    verts=[]; faces=[]
    section=[(-.7,-1),(.7,-1),(1,-.7),(1,.7),(.7,1),(-.7,1),(-1,.7),(-1,-.7)]
    for i,p in enumerate(points):
        tangent=(Vector(points[min(i+1,len(points)-1)])-Vector(points[max(0,i-1)])).normalized()
        a=(Vector((1,0,0))-tangent*tangent.x).normalized()
        b=tangent.cross(a).normalized()
        for x,y in section: verts.append(tuple(Vector(p)+a*x*depth+b*y*width))
    for j in range(len(points)-1):
        for k in range(8):
            a=j*8+k; b=j*8+(k+1)%8
            faces.append((a,b,b+8,a+8))
    faces.extend([tuple(reversed(range(8))),tuple((len(points)-1)*8+k for k in range(8))])
    return mesh(name,verts,faces,material,parent,True)

def disc(name,at,r,depth,material,parent,axis='z',segments=32):
    points=[]
    for side in [-1,1]:
        for k in range(segments):
            c=math.cos(math.tau*k/segments); s=math.sin(math.tau*k/segments)
            q=(r*c,r*s,side*depth/2) if axis=='z' else (side*depth/2,r*c,r*s)
            points.append(tuple(at[i]+q[i] for i in range(3)))
    faces=[]
    for i in range(segments):
        j=(i+1)%segments; faces.append((i,j,j+segments,i+segments))
    faces += [tuple(reversed(range(segments))),tuple(range(segments,segments*2))]
    return mesh(name,points,faces,material,parent,True,bevel=.002)

def grid(name, fn, nu, nv, material,parent,solid=0,flip=False):
    verts=[fn(i/nu,j/nv) for i in range(nu+1) for j in range(nv+1)]
    faces=[]
    for i in range(nu):
        for j in range(nv):
            a=i*(nv+1)+j; f=(a,a+nv+1,a+nv+2,a+1)
            faces.append(tuple(reversed(f)) if flip else f)
    return mesh(name,verts,faces,material,parent,True,solid)

# Slightly crowned side surface. Wheel openings closely follow the tyre profile.
def side_x(y,z):
    t=max(0,min(1,(y-.50)/.55))
    x=.765+.057*math.sin(t*math.pi*.92)
    x-=.035*max(0,(abs(z)-1.60)/.38)
    return x

def top_y(z):
    if z<-.70: return 1.055 + .05*(z+.70)
    if z>1.55: return 1.04-.025*(z-1.55)
    return 1.04

shell_parts=[]
for side in [-1,1]:
    intervals=[(-1.96,-1.62,None),(-1.62,-.82,-1.22),(-.82,-.665,None),(.495,.83,None),(.83,1.63,1.23),(1.63,1.96,None)]
    for index,(z0,z1,wheel) in enumerate(intervals):
        def f(u,v,side=side,z0=z0,z1=z1,wheel=wheel):
            z=z0+(z1-z0)*u; lower=.51
            if wheel is not None and abs(z-wheel)<.35:
                lower=max(lower,.425+math.sqrt(max(0,.35**2-(z-wheel)**2)))
            y=lower+(top_y(z)-lower)*v
            flare=.014*math.sin(math.pi*u)*(1-v) if wheel is not None else 0
            return (side*(side_x(y,z)+flare),y,z)
        shell_parts.append(grid('ShellPatch',f,32 if wheel else 8,8,paint,body,.018,side>0))
    # Rolled arch edges and dark recessed liners.
    for zc in [-1.22,1.23]:
        a0=math.asin((.51-.425)/.35)
        points=[]
        for i in range(41):
            a=a0+(math.pi-2*a0)*i/40
            y=.425+.355*math.sin(a); z=zc+.355*math.cos(a)
            points.append((side*(side_x(y,z)+.009),y,z))
        shell_parts.append(tube('ArchRolledLip',points,.009,paint,body,8))
        tube('WheelArchLiner',[(side*.773,.425+.345*math.sin(a0+(math.pi-2*a0)*i/40),zc+.345*math.cos(a0+(math.pi-2*a0)*i/40)) for i in range(41)],.027,black,body,8)
    cube('Sill',(.075,.075,1.43),(side*.777,.532,.07),paint,body,.025)
    cube('RearSideMoulding',(.023,.055,1.02),(side*.821,.77,1.005),black,body,.012)
    # Rounded fender crowns connect the vertical wing to the bonnet seam.
    def crown(u,v,side=side):
        z=-1.96+1.30*u; y=top_y(z)
        return (side*(.751*(1-v)+side_x(y,z)*v),y+.006*math.sin(math.pi*v),z)
    grid('FenderCrown',crown,24,5,paint,body,.012,side<0)
    # A- and C-pillars are body-coloured curved rails, rather than straight blocks.
    sheet_rail('APillar',[(side*.735,1.045,-.74),(side*.712,1.19,-.57),(side*.681,1.35,-.37),(side*.654,1.48,-.19)],.033,.014,paint,body)
    sheet_rail('CPillar',[(side*.672,1.48,1.10),(side*.712,1.34,1.30),(side*.755,1.15,1.54),(side*.779,1.04,1.65)],.060,.018,paint,body)
    tube('RoofGutter',[(side*.665,1.49,-.20),(side*.698,1.515,.10),(side*.699,1.52,.75),(side*.672,1.48,1.10)],.009,black,body,8)
    # Quarter glass slopes inward towards the roof.
    def quarter(u,v,side=side):
        zlo=.50+1.11*u; zhi=.50+.56*u
        return (side*(.772-.10*v),1.055+.414*v,zlo*(1-v)+zhi*v)
    grid('QuarterWindow',quarter,12,5,glass,fixedglass,flip=side>0)
    tube('QuarterWindowSeal',[(side*.772,1.055,.50),(side*.772,1.055,1.61),(side*.672,1.469,1.06),(side*.672,1.469,.50),(side*.772,1.055,.50)],.013,black,body,8)

# Join painted fixed fender patches into the adapter's Shell mesh.
bpy.ops.object.select_all(action='DESELECT')
for obj in shell_parts: obj.select_set(True)
bpy.context.view_layer.objects.active=shell_parts[0]
bpy.ops.object.convert(target='MESH'); bpy.ops.object.join()
bpy.context.object.name='Shell'

# Curved bonnet with stamped ridges and a real thickness. Local to its rear hinge.
def hood_surface(u,v):
    x=(u*2-1)*(.762-.006*math.cos(v*math.pi))
    z=-1.215+1.215*v
    y=-.065+.065*v+.023*(1-(u*2-1)**2)*math.sin(v*math.pi*.9)
    return x,y,z
grid('HoodPanel',hood_surface,24,18,paint,hood,.025,True)
for side in [-1,1]:
    tube('HoodCrease',[(side*(.49+.03*v),-.062+.065*v+.012,-1.195+1.17*v) for v in [i/25 for i in range(26)]],.003,paint,hood,6)
grid('HoodLiner',lambda u,v: ((u*2-1)*.62,-.10+.065*v,-1.10+1.04*v),12,12,black,hood,.008,True)

# Crowned roof and gently bowed windscreen.
grid('Roof',lambda u,v: ((u*2-1)*(.674+.024*math.sin(v*math.pi)),1.489+.050*(1-(u*2-1)**2)-.012*(2*v-1)**4,-.22+1.36*v),28,20,paint,body,.028,True)
def windscreen(u,v):
    t=u*2-1; width=.726-.075*v
    return (t*width,1.045+.437*v,-.76+.55*v-.035*(1-t*t))
grid('Windshield',windscreen,24,14,glass,fixedglass,flip=True)
for a,b in [(0,1)]:
    tube('WindscreenLowerSeal',[windscreen(i/32,0) for i in range(33)],.014,black,body)
    tube('WindscreenUpperSeal',[windscreen(i/32,1) for i in range(33)],.014,black,body)
for x in [-.37,.28]:
    tube('WiperArm',[(x,1.066,-.76),(x+.22,1.078,-.75)],.008,black,body,6)
    tube('WiperBlade',[(x+.12,1.083,-.755),(x+.37,1.085,-.748)],.009,black,body,6)

# Front and rear bumper lofts with rounded plan views.
def bumper(name,front=True):
    rings=[(.43,.73,.040),(.46,.80,.065),(.55,.835,.055),(.68,.834,.015),(.74,.805,-.015)]
    verts=[]
    for y,w,bulge in rings:
        for k in range(33):
            t=-1+2*k/32; x=t*w
            z=(-1.925-bulge-.07*(1-t*t)) if front else (1.915+bulge+.045*(1-t*t))
            verts.append((x,y,z))
    faces=[]
    for j in range(len(rings)-1):
        for i in range(32):
            a=j*33+i; face=(a,a+1,a+34,a+33)
            faces.append(tuple(reversed(face)) if front else face)
    return mesh(name,verts,faces,paint,body,True,.035)
bumper('FrontBumper'); bumper('RearBumper',False)
for front in [True,False]:
    z=-2.00 if front else 1.97
    tube('BumperRubStrip',[(x,.748,z+(.07 if front else -.03)*(abs(x)/.80)**2) for x in [-.80+i*.05 for i in range(33)]],.033,black,body,12)
# The G3-inspired twin headlamp/central grille arrangement.
cube('Grille',(.60,.188,.036),(0,.891,-1.975),black,body,.022)
for y in [.842,.886,.930]:
    cube('GrilleSlat',(.59,.014,.020),(0,y,-2.0),black,body,.006)
disc('RoundBadge',(0,.89,-2.018),.072,.016,chrome,body)
disc('BadgeInset',(0,.89,-2.030),.058,.010,black,body)
# Original mesh lines suggest the Volkswagen monogram, no downloaded logo texture.
for points in [[(-.038,.918,-2.039),(-.015,.874,-2.039),(0,.902,-2.039),(.015,.874,-2.039),(.038,.918,-2.039)],[(-.033,.887,-2.039),(-.015,.859,-2.039),(0,.881,-2.039),(.015,.859,-2.039),(.033,.887,-2.039)]]:
    tube('BadgeStroke',points,.0045,chrome,body,8)
for side in [-1,1]:
    x=side*.555
    contour=[(.313,.816),(.316,.954),(.345,.980),(.667,.980),(.755,.953),(.786,.881),(.771,.824),(.739,.806)]
    # A tapered housing and bowed clear lens replace the rectangular front blocks.
    vertices=[]
    for offset in [0,.068]:
        for px,py in contour:
            vertices.append((side*px,py,-2.010+.031*(px/.80)**2+offset))
    n=len(contour)
    faces=[tuple(reversed(range(n))),tuple(range(n,2*n))]
    for i in range(n): faces.append((i,(i+1)%n,(i+1)%n+n,i+n))
    mesh('HeadlampHousing',vertices,faces,black,body,True,bevel=.010)
    for dx,r in [(-.105,.085),(.086,.067)]:
        verts=[]; faces=[]
        for ring in range(6):
            rr=r*ring/5
            for k in range(32):
                a=k*math.tau/32
                verts.append((x+side*dx+rr*math.cos(a),.891+rr*.88*math.sin(a),-2.014+.025*(1-(ring/5)**2)))
        for ring in range(5):
            for k in range(32):
                a=ring*32+k; b=ring*32+(k+1)%32
                faces.append((a,b,b+32,a+32))
        mesh('HeadlampReflector',verts,faces,reflector,body,True)
        disc('HeadlampBulb',(x+side*dx,.891,-2.012),r*.36,.017,white,body)
        # Concentric reflector rings give visible lens depth.
        points=[(x+side*dx+math.cos(i*math.tau/32)*r*.86,.891+math.sin(i*math.tau/32)*r*.86,-2.014) for i in range(33)]
        tube('ReflectorRing',points,.0035,chrome,body,6)
    lens_vertices=[(side*.55,.895,-2.027)]
    for px,py in contour:
        lens_vertices.append((side*(.55+(px-.55)*.97),.895+(py-.895)*.94,-2.019+.031*(px/.8)**2))
    mesh('HeadlampLens',lens_vertices,[(0,i+1,(i+1)%n+1) for i in range(n)],lens,body,True)
    cube('Indicator',(.045,.14,.015),(side*.751,.888,-2.003),white,body,.012)
    # Fog lights sit in the dark bumper insets.
    cube('FogRecess',(.275,.135,.020),(side*.565,.548,-2.050),black,body,.042)
    disc('FogLightRim',(side*.565,.547,-2.066),.060,.012,chrome,body)
    disc('FogLight',(side*.565,.547,-2.075),.048,.012,lens,body)
    cube('TailLampHousing',(.215,.34,.09),(side*.682,.903,1.936),black,body,.045)
    cube('TailLampRed',(.186,.226,.020),(side*.682,.938,1.987),red,body,.034)
    cube('TailLampReverse',(.184,.066,.022),(side*.682,.811,1.989),white,body,.012)
    cube('TailLampAmber',(.184,.048,.023),(side*.682,.867,1.991),amber,body,.010)
cube('LowerGrille',(.65,.132,.020),(0,.535,-2.065),black,body,.027)
for y in [.50,.53,.56]: cube('LowerSlat',(.62,.010,.012),(0,y,-2.078),black,body,.004)
cube('FrontPlateMount',(.37,.10,.018),(0,.683,-2.055),black,body,.012)
cube('RearPlateMount',(.38,.12,.018),(0,.80,1.989),black,body,.012)

# Front doors retain their pivots and material slots.
for side,parent in [(-1,left),(1,right)]:
    def door_surface(u,v,side=side):
        z=-.66+1.15*u; y=.555+.495*v
        return (side*(side_x(y,z)-.82),y-.57,z+.66)
    grid('DoorPanel',door_surface,20,16,paint,parent,.024,side>0)
    cube('DoorInsert',(.035,.305,.91),(-side*.065,.22,.57),interior,parent,.055)
    cube('DoorArmrest',(.09,.06,.44),(-side*.087,.26,.63),interior,parent,.025)
    cube('InnerDoorHandle',(.018,.05,.13),(-side*.112,.35,.35),black,parent,.014)
    cube('DoorHandle',(.030,.055,.165),(side*.005,.422,.94),black,parent,.023)
    cube('Moulding',(.028,.055,1.13),(side*.001,.20,.57),black,parent,.014)
    def door_glass(u,v,side=side):
        z0=1.135*u; z1=.47+.665*u
        return (side*(-.048-.117*v),.485+.414*v,z0*(1-v)+z1*v)
    grid('DoorGlass',door_glass,16,8,glass,parent,flip=side>0)
    path=[door_glass(0,0),door_glass(1,0),door_glass(1,1),door_glass(0,1),door_glass(0,0)]
    tube('WindowSeal',path,.014,black,parent,10)
    tube('DoorWindowFrame',path,.020,paint,parent,10)
    cube('BPost',(.035,.44,.070),(-side*.10,.69,1.12),black,parent,.009)
    cube('MirrorBase',(.11,.15,.17),(side*.01,.55,.10),black,parent,.035)
    cube('MirrorHousing',(.19,.145,.205),(side*.075,.56,.10),black,parent,.055)
    cube('MirrorGlass',(.14,.108,.009),(side*.078,.56,.204),mirror,parent,.028)

# Hatch: framed curved rear window and a painted lower pressing.
def rear_glass(u,v):
    t=2*u-1
    return (t*(.655+.075*v),-.035-.46*v,.02+.54*v+.018*(1-t*t))
grid('RearGlass',rear_glass,24,12,glass,hatch,flip=True)
for v in [0,1]: tube('HatchHorizontalSeal',[rear_glass(i/32,v) for i in range(33)],.025,black,hatch)
for u in [0,1]: tube('HatchSideFrame',[rear_glass(u,i/20) for i in range(21)],.029,paint,hatch)
def rear_panel(u,v):
    t=2*u-1
    return (t*(.735-.02*v),-.497-.255*v,.568+.26*v+.015*(1-t*t))
grid('HatchPanel',rear_panel,24,10,paint,hatch,.032,True)
cube('HatchHandle',(.22,.045,.025),(0,-.62,.714),black,hatch,.014)
tube('RearWiper',[(-.18,-.46,.551),(.17,-.42,.515)],.009,black,hatch,8)
cube('RearValance',(1.39,.16,.06),(0,.70,1.926),paint,body,.035)

# Rounded seats and detailed, still simplified interior.
cube('CabinFloor',(1.40,.05,2.1),(0,.60,.28),interior,cabin,.025)
cube('Dashboard',(1.34,.19,.35),(0,1.025,-.48),interior,cabin,.075)
cube('InstrumentBinnacle',(.38,.13,.17),(-.36,1.135,-.45),instrument,cabin,.040)
for x in [-.44,-.29]:
    disc('GaugeFace',(x,1.155,-.354),.048,.009,instrument,cabin)
    points=[(x+math.cos(i*math.tau/32)*.045,1.155+math.sin(i*math.tau/32)*.045,-.348) for i in range(33)]
    tube('GaugeRing',points,.003,chrome,cabin,6)
    tube('GaugeNeedle',[(x,1.155,-.341),(x-.025,1.178,-.341)],.002,white,cabin,6)
for x in [-.58,.11,.40]:
    cube('AirVent',(.15,.047,.018),(x,1.06,-.295),instrument,cabin,.010)
    for k in range(4): cube('VentSlat',(.135,.003,.008),(x,1.044+k*.010,-.283),black,cabin,.001)
cube('Console',(.24,.25,.28),(0,.79,-.23),interior,cabin,.035)
cube('Radio',(.17,.065,.020),(0,.96,-.27),instrument,cabin,.008)
tube('GearLever',[(0,.77,-.05),(0,.93,-.07)],.012,black,cabin)
disc('GearKnob',(0,.94,-.07),.028,.045,black,cabin,axis='x')
for x in [-.36,.36]:
    cube('SeatCushion',(.48,.15,.52),(x,.77,.16),seat,cabin,.065)
    cube('SeatBack',(.46,.48,.16),(x,1.06,.38),seat,cabin,.060)
    cube('Headrest',(.25,.17,.12),(x,1.37,.38),seat,cabin,.045)
    for side in [-1,1]:
        cube('SeatBolster',(.075,.44,.19),(x+side*.21,1.045,.355),seat_trim,cabin,.034)
        cube('SeatCushionBolster',(.075,.14,.49),(x+side*.21,.80,.16),seat_trim,cabin,.028)
    for dx in [-.15,.15]:
        tube('SeatStitch',[(x+dx,.852,-.025),(x+dx,.854,.29)],.0018,seat_trim,cabin,6)
cube('RearBench',(1.18,.35,.17),(0,.965,.89),seat,cabin,.055)
cube('TrunkFloor',(1.35,.04,.87),(0,.615,1.38),interior,cabin,.015)
for side in [-1,1]:
    def wheel_tub(u,v,side=side):
        a=math.pi*v
        return (side*(.50+.28*u),.425+.345*math.sin(a),1.23+.345*math.cos(a))
    grid('InnerWheelTub',wheel_tub,4,32,interior,cabin,.012,side<0)
# Open steering wheel, unlike the previous solid cylinder.
points=[(-.36+math.cos(i*math.tau/48)*.14,1.14+math.sin(i*math.tau/48)*.14,-.20) for i in range(49)]
tube('SteeringWheel',points,.018,black,cabin,10)
cube('SteeringHub',(.105,.07,.05),(-.36,1.14,-.20),black,cabin,.023)
for a in [0,math.pi,math.pi*1.5]:
    tube('SteeringSpoke',[(-.36,1.14,-.20),(-.36+math.cos(a)*.125,1.14+math.sin(a)*.125,-.20)],.012,black,cabin,8)

# Geometry integrity and outward normals. Blender exports Y-up via glTF.
for obj in list(bpy.context.scene.objects):
    if obj.type=='MESH':
        bpy.context.view_layer.objects.active=obj
        obj.select_set(True)
        for mod in list(obj.modifiers):
            bpy.ops.object.modifier_apply(modifier=mod.name)
        # Signed outside for solids; single-sided glass is rendered double-sided by adapter.
        if obj.data.polygons:
            bpy.ops.object.mode_set(mode='EDIT')
            bpy.ops.mesh.select_all(action='SELECT')
            bpy.ops.mesh.normals_make_consistent(inside=False)
            bpy.ops.object.mode_set(mode='OBJECT')
        obj.select_set(False)

triangles=sum(sum(len(p.vertices)-2 for p in obj.data.polygons) for obj in bpy.context.scene.objects if obj.type=='MESH')
print(f'GOL_STUDY: {triangles} triangles; original parametric geometry')
assert triangles<90000,triangles
bpy.context.preferences.filepaths.save_version=0
source = ROOT/'tools/blender/source'
source.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=str(source/'gol_study.blend'))
bpy.ops.export_scene.gltf(filepath=str(OUT/'gol_study.glb'),export_format='GLB',export_yup=True,export_apply=True,export_materials='EXPORT',export_cameras=False,export_lights=False)
print('EXPORTED:',OUT/'gol_study.glb')
