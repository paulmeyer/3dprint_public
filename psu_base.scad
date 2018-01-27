
// select to create the psu_base or the bottom plate

//create_base = true;
//create_bottom_plate = false;
//create_shim = false;

//create_base = false;
//create_bottom_plate = true;
//create_shim = false;

create_base = false;
create_bottom_plate = false;
create_shim = true;



// todo:
//   - fix outer wall sizes (done)
//   - add base plate (done)

//   - add psu attach holes (done)
//   - add buttresses (done)
//   - add inside ledge (done)
//
//   - add rail attach
//   - bevel corners
//   - bolt_reinforcements

//   - add base plate attach tabs
//   - add base plate attach holes

// curve fineness
$fn = 20;

//**********
// orientation reference:
//   bottom: side of PSU towards table (-x)
//   frameside: side of PSU towards mk3 frame (-y)
//   back: side of PSU away from frame (+y)
//   inside: side of PSU towards rails and Einsy (+z)
//   outside: side of PSU with switch/plug

//  The origin is defined as the bottom/outside/frameside corner of the PSU body
//    +X is up (away from the table with PSU mounted on mk3)
//    +Y is back (away from the frame)
//    +Z is inside (towards the Einsy)

// measured constants are all in mm units


//**********
// meanwell NES-350-24 measurements
psu_length = 215;
psu_width = 115;
psu_height = 50;

// inside face 4mm tapped holes, 32.5 from bottom and frame/back corner
psu_inside_hole_vertical = 32.5;
psu_inside_hole_edge     = 32.5;

// frame face 4mm tapped holes, 2 near inside corner
psu_frame_hole_edge = 12.5;
psu_frame_hole1_x = 32.5;
psu_frame_hole2_x = 182.5;

// back face 4mm tapped holes, 4
psu_back_hole_edge = 12.5;
psu_back_hole1_x = 32.5;
psu_back_hole2_x = 182.5;


// prusa y hole positions.  x relative to top of rail, z relative to center of rail
y_hole1_x = 56;
y_hole2_x = y_hole1_x + 117;

y_hole_z = psu_height - 12.5;


// bottom_plate

bp_edge_t = 2;

ra_width = 33;
ra_depth = 17;
ra_f_chamfer = 5;
ra_r_chamfer = 3;
ra_t = bp_edge_t + 3;

//**********
// desired hole size for through 3mm bolt (not tapped)
hole_3mm_bolt = 3.1;
hole_3mm_bolt_r = hole_3mm_bolt/2;

// desired hole size for through 3mm bolt (tapped)
hole_3mm_bolt_tapped = 3;
hole_3mm_bolt_tapped_r = hole_3mm_bolt_tapped/2;

// desired hole size for through 4mm bolt (not tapped)
hole_4mm_bolt = 4.1;
hole_4mm_bolt_r = hole_4mm_bolt/2;





// general size of base
base_psu_overlap = 50;
base_height = 100;

side_wall_t   = 2.5;
back_wall_t   = 4;
frame_wall_t  = 6;

// buttress
buttress_t = 3;
buttress_w = 14;
buttress_h = base_height;

buttress_top_chamfer = 5;
buttress_bottom_chamfer = bp_edge_t;


//********************
// measured from Prusa PSU base
//********************

//**********
// wire exit (two half circles connected by rectangle, for wires to Einsy)
//   diameter of end circles
wire_exit_d = 6.5;
//   distance between centers of end circles
wire_exit_width = 10;
//   distance from the frame side of the PSU to the center of the opening
//wire_exit_front_offset = 20;  //prusa version is 20, shifting forward to avoid buttress conflict
wire_exit_front_offset = 17;

//**********
// slot for mains supply plug, flush to bottom of 
//   width/height
plug_slot_width = 27.25;
plug_slot_height = 32;
//   distance back edge of slot to back
plug_slot_back_offset = 20;

//   bottom plate thickness (offset of bottom of assembly to slot)
plug_slot_bottom_offset = bp_edge_t;

//   distance from edge of slot to center of bolt holes
plug_screw_offset_h = 5;
//   distance from bottom of base to bolt holes
plug_screw_offset_v = 16.5;

//**********
// rectangular hole for power switch

//   height/width
switch_height = 20;
switch_width = 12.5;

//   distance from frame side of base to edge of hole
switch_frame_offset = 8.5;
//   distance from bottom of base to edge of hole
switch_bottom_offset = 3 + bp_edge_t;

//**********
//**********

// outside/frame/bottom corner of whole base assembly (including bottom plate)

base_outer_position = [   -(base_height - base_psu_overlap),
                          -frame_wall_t,
                          -side_wall_t ];

base_outer_size =     [ base_height,
                        psu_width + frame_wall_t + back_wall_t,
                        psu_height + 2*side_wall_t ];

switch_hole_size     = [switch_height,switch_width, side_wall_t];
switch_hole_position = base_outer_position + 
                       [  switch_bottom_offset,
                          switch_frame_offset,
                          0 ];

plug_slot_size     = [plug_slot_height, plug_slot_width, side_wall_t];
plug_slot_position = base_outer_position + 
                     [  plug_slot_bottom_offset,
                        base_outer_size[1]-plug_slot_back_offset-plug_slot_width,
                        0  ];




wire_exit_center = base_outer_position + 
                   [  wire_exit_d/2 + bp_edge_t,
                      wire_exit_front_offset+wire_exit_width/2,
                      base_outer_size[2]-side_wall_t/2  ];

ledge_width = 3;  
ledge_height = 8;



// slot for frame side shim

shim_base_depth = 50;
shim_base_edge  = 4;

shim_width = base_outer_size[2] - 2*shim_base_edge;
shim_thickness = 6;
shim_height = 190;





//**************
//* draw base

if(create_base && create_bottom_plate && create_shim){
  psu_base(create_base, create_bottom_plate);

  shim();

} else if (create_base) {
  difference(){
    psu_base(create_base, create_bottom_plate);
    base_plate_container();
  }
} else if (create_bottom_plate) {
  intersection(){
    psu_base(create_base, create_bottom_plate);
    base_plate_container();
  }
} else {

  shim();


}


//*****************
//* module
//*****************


// main(){

module psu_base(base, bottom_plate){

  // build the outer shell, then knock all the holes in it
  difference(){

    union(){
      // main shell
      outer_shell();
      buttresses();
      plug_hole_reinforce();
      psu_ledge();
      rail_attach();

      back_bump();  // thicker space to slide above back frame

      base_plate_tabs();

    }


    base_plate_tabs(holes = true);

    frame_side_opening();
    plug_hole();
    switch_hole();
    wire_exit();
    bottom_plate_screws();
    psu_base_screws();
    back_lift();  // thicker space to slide above back frame
  }


}




module psu_block(){
    cube([psu_length, psu_width, psu_height]);
}

module outer_shell(){
    difference()
    {
      translate(base_outer_position) cube(base_outer_size);
      // cut out a psu_block width/height hole
      psu_block();
      wire_space();
    }
}

module buttresses(){
  // inside edge, thicker portions around/under inside PSU attach screws
  // full height of base (including bottom plate)
  // chamfered at top/bottom

  //**
  // base positions for buttresses
  position1 = base_outer_position + [base_height/2,psu_inside_hole_edge+frame_wall_t,base_outer_size[2] + buttress_t/2];
  position2 = base_outer_position + [base_height/2,base_outer_size[1] - psu_inside_hole_edge-back_wall_t,base_outer_size[2] + buttress_t/2];

  //**
  // top chamfer (5mm)
   
  // triangle origin, top of buttress where it meets the base wall
  pt1 = [0,0]; 
  pt2 = [pt1[1], pt1[0] + buttress_t];
  pt3 = [pt1[1] - buttress_top_chamfer, pt1[0] + buttress_t];
  top_chamfer_pos = base_outer_position + base_outer_size;

  //**
  // bottom chamfer
  // triangle origin, top of buttress where it meets the base wall
  pt4 = [0,0]; 
  pt5 = [pt1[1], pt1[0] + buttress_t];
  pt6 = [pt1[1] + buttress_bottom_chamfer, pt1[0] + buttress_t];
  bottom_chamfer_pos = base_outer_position + [0,base_outer_size[1],base_outer_size[2]];

  


  difference(){
    union(){ 
      translate(position1) cube([buttress_h,buttress_w,buttress_t], center = true);
      translate(position2) cube([buttress_h,buttress_w,buttress_t], center = true);
    }
  
    translate(top_chamfer_pos)     rotate([90,0,0]) linear_extrude(height = base_outer_size[1]) polygon(points = [pt1,pt2,pt3]);
    translate(bottom_chamfer_pos)  rotate([90,0,0]) linear_extrude(height = base_outer_size[1]) polygon(points = [pt4,pt5,pt6]);
  }
}

module psu_ledge(){
  // 5mm ledge for PSU to rest on in base
  // full width of back wall
  // short segment on inside/outside wall

  chamfer_height = 8;

  short_ledge_extent = 20;
  short_ledge_frame_offset = 25;

  ledge_pts = [[0,0], 
               [ledge_height,0], 
               [ledge_height,ledge_width], 
               [-chamfer_height,ledge_width]];
  
  ledge1_pos = [-ledge_height,psu_width - ledge_width,0];
  translate(ledge1_pos) linear_extrude(height = psu_height) polygon(points = ledge_pts);

  ledge2_pos = [-ledge_height,short_ledge_frame_offset,ledge_width];
  translate(ledge2_pos) rotate([-90,0,0]) linear_extrude(height = short_ledge_extent) polygon(points = ledge_pts);  

  ledge3_pos = [-ledge_height,short_ledge_frame_offset + short_ledge_extent,psu_height - ledge_width];
  translate(ledge3_pos) rotate([90,0,0]) linear_extrude(height = short_ledge_extent) polygon(points = ledge_pts);  

}

module rail_attach(){

  sp_bot_flat = 2;
  sp_top_flat = 4.5;
  sp_height = 17 + bp_edge_t;
  sp_t = 5;
 
  hole_spacing = 20;
  hole_d = 3.2;
  hole_l = 6;
  hole_base_distance = 10;

  //** base
  base_poly = [ [0, 0],
                [0, ra_depth - ra_f_chamfer],
                [ra_f_chamfer, ra_depth],
                [ra_width - ra_r_chamfer, ra_depth],
                [ra_width, ra_depth-ra_r_chamfer],
                [ra_width, 0]];

  ra_pos = [base_outer_position[0],
            base_outer_position[1] + base_outer_size[1] - back_wall_t - psu_inside_hole_edge - ra_width/2 - buttress_w/2 - sp_t/2,
            base_outer_position[2] + base_outer_size[2]];


  //** angle support
  support_poly = [ [0,                  0],
		   [0,                  -ra_depth],
		   [sp_bot_flat + ra_t, -ra_depth],
		   [sp_height,          -sp_top_flat],
		   [sp_height,          0]];

//  sp_pos = [base_outer_position[0],
//            base_outer_position[1] + base_outer_size[1] - back_wall_t - psu_inside_hole_edge + buttress_w/2,
//            base_outer_position[2] + base_outer_size[2]];

  sp_pos = ra_pos + [0,ra_width/2 - sp_t/2,0 ];

  // holes

  h_pos1 = ra_pos + [ra_t/2,ra_width/2+hole_spacing/2,hole_base_distance];
  h_pos2 = ra_pos + [ra_t/2,ra_width/2-hole_spacing/2,hole_base_distance];


  difference(){
    union() {
      translate(ra_pos) rotate([90,0,90]) linear_extrude(height=ra_t) polygon(points = base_poly);
      translate(sp_pos) rotate([-90,0,0]) linear_extrude(height=sp_t) polygon(points = support_poly);
    }
    translate(h_pos1) rotate([0,90,0]) ra_slot(hole_d/2, 2.5, ra_t);
    translate(h_pos2) rotate([0,90,0]) ra_slot(hole_d/2, 2.5, ra_t);
  }
}

module ra_slot(radius, circle_d, depth){
  translate([circle_d/2,0,0])  cylinder(h = depth*1.1, r=radius, center = true);
  translate([-circle_d/2,0,0]) cylinder(h = depth*1.1, r=radius, center = true);
  translate([0,0,0]) cube([circle_d, 2*radius, depth*1.1], center = true);
}


module back_bump(){
  // solid lip in back of base, lid won't go there
  //  provides 2mm clearance for rear frame piece of i3

  bump_y = ledge_width + back_wall_t;
  bump_x = 25;
  bump_z = base_outer_size[2];

  bump_pos = [base_outer_position[0],
              base_outer_position[1] + base_outer_size[1] - bump_y, 
              base_outer_position[2] + base_outer_size[2] - bump_z];

  translate(bump_pos) cube([bump_x,bump_y,bump_z]);
}

module back_lift(){
  // gap in bottom of back for frame

  lift_x = bp_edge_t;
  lift_y = ledge_width + back_wall_t - 1.2;
  lift_z = base_outer_size[2];

  lift_pos = [base_outer_position[0],
              base_outer_position[1] + base_outer_size[1] - lift_y, 
              base_outer_position[2] + base_outer_size[2] - lift_z];

  translate(lift_pos) cube([lift_x,lift_y,lift_z]);
}


module wire_space(){
    translate(base_outer_position + [bp_edge_t,frame_wall_t, side_wall_t])
      cube( [ base_height - base_psu_overlap - bp_edge_t, 
              base_outer_size[1] - frame_wall_t - back_wall_t,
              base_outer_size[2] - 2*side_wall_t]);
}

module plug_hole(){

  translate(plug_slot_position) cube(plug_slot_size);

  // screw positions relative to plug slot position
  screw1_position = [plug_screw_offset_v,-plug_screw_offset_h,0];
  screw2_position = [plug_screw_offset_v, plug_screw_offset_h + plug_slot_width,0];
    
  translate(plug_slot_position + screw1_position) bolt_hole_3mm(side_wall_t);
  translate(plug_slot_position + screw2_position) bolt_hole_3mm(side_wall_t);
  
}

module plug_hole_reinforce(positive = true){

  lock_nut_width_cc = 6;
  lock_nut_slot_height = 2;

  ph_re_width  = 9;
  ph_re_length = 9;

  // screw positions relative to plug slot position
  ph_reinforce_1 = plug_slot_position + [plug_screw_offset_v,-plug_screw_offset_h,0] + [0,0,side_wall_t];
  ph_reinforce_2 = plug_slot_position + [plug_screw_offset_v, plug_screw_offset_h + plug_slot_width,0]  + [0,0,side_wall_t];

  translate(ph_reinforce_1) ph_reinforce();
  translate(ph_reinforce_2) ph_reinforce();

  module ph_reinforce(){
    difference(){
      translate([0,-ph_re_width/2,0]) cube([ph_re_length, ph_re_width, lock_nut_slot_height]);
      linear_extrude(height = lock_nut_slot_height) circle(lock_nut_width_cc/2, $fn = 6);
    }
  }
}


module switch_hole(){
  translate(switch_hole_position) cube(switch_hole_size);
}

module wire_exit(){
  translate(wire_exit_center) wire_exit_shape();
}

module wire_exit_shape(){
  cube([wire_exit_d, wire_exit_width, side_wall_t], center = true);
  translate([0,wire_exit_width/2,0]) cylinder(h=side_wall_t, r=wire_exit_d/2, center=true);
  translate([0,-wire_exit_width/2,0]) cylinder(h=side_wall_t, r=wire_exit_d/2, center=true);
}

module bottom_plate_screws(){
}

module psu_base_screws(){

  // inside face bolt holes, extend through buttresses then side wall

  position1 = [psu_inside_hole_vertical, psu_inside_hole_edge,             psu_height + side_wall_t + buttress_t];  // outside of buttress
  position2 = [psu_inside_hole_vertical, psu_width - psu_inside_hole_edge, psu_height + side_wall_t + buttress_t];  // outside of buttress

  translate(position1) rotate([0,180,0]) bolt_hole_4mm(side_wall_t + buttress_t, c = false);
  translate(position2) rotate([0,180,0]) bolt_hole_4mm(side_wall_t + buttress_t, c = false);

  // back holes
  position3 = [psu_back_hole1_x, psu_width + back_wall_t, psu_back_hole_edge];
  position4 = [psu_back_hole1_x, psu_width + back_wall_t, psu_height - psu_back_hole_edge];
  translate(position3) rotate([90,0,0]) bolt_hole_4mm(back_wall_t, c = false);
  translate(position4) rotate([90,0,0]) bolt_hole_4mm(back_wall_t, c = false);




}

module frame_side_opening(){
  depth = shim_base_depth;
  edge  = shim_base_edge;
  slot_size = [depth, frame_wall_t, base_outer_size[2] - 2*edge];
  slot_pos = [base_psu_overlap-depth, -frame_wall_t, edge - side_wall_t];
  translate(slot_pos) cube(slot_size);
}


module base_plate_tabs(holes = false){

  tab_outside_pos = [base_outer_position[0],40,-side_wall_t ];
  tab_outside_rot = [0,0,0];

  tab_inside_pos = [base_outer_position[0],50,base_outer_position[2] + base_outer_size[2] ];
  tab_inside_rot = [180,0,0];

  tab_back_pos = [base_outer_position[0],
                  base_outer_position[1] + base_outer_size[1] - ledge_width,
                  base_outer_position[2] + base_outer_size[2]/2 ];
  tab_back_rot = [90,0,0];

  tab_frame_pos = [base_outer_position[0],
                   base_outer_position[1],
                   base_outer_position[2] + base_outer_size[2]/2 ];
  tab_frame_rot = [-90,0,0];

  translate(tab_outside_pos) rotate(tab_outside_rot) side_plate_tab(holes);
  translate(tab_inside_pos)  rotate(tab_inside_rot)  side_plate_tab(holes);
  translate(tab_back_pos)    rotate(tab_back_rot)    side_plate_tab(holes, width=30);
  translate(tab_frame_pos)   rotate(tab_frame_rot)   side_plate_tab(holes, width=30);

}

module side_plate_tab(holes = false, width = 15){

  height = 13;
  depth  = 10;  // including side wall of 2.5, wall_thickening of 2.5, lid_tab of 5

  hole_height = 8;

  nut_width = 5.5;
  nut_t     = 1.7;

  slot_offset = depth * (3/4);
  

  points = [[0,0],
            [0,               width/2],
            [height * (3/4),  width/2],
            [height,          width/2 - height/4],
            [height,          -width/2 + height/4],
            [height * (3/4),  -width/2],
            [0,               -width/2]];

  if(!holes){
    linear_extrude(height = depth) polygon(points);
  } else {
    translate([hole_height,0,0]) bolt_hole_3mm(depth);
    translate([0,-nut_width/2,slot_offset-nut_t/2]) cube([hole_height + nut_width/2 + 1,nut_width,nut_t]);
  }

}

module end_plate_tab(holes = false){

  cube([10,10,10]);

}





module bolt_hole_3mm(depth, center = false){
  cylinder(h=depth, r=hole_3mm_bolt_r, centered = center);
}

module bolt_hole_3mm_tapped(depth, center = false){
  cylinder(h=depth, r=hole_3mm_bolt_tapped_r, centered = center);
}

module bolt_hole_4mm(depth, c = false){
  cylinder(h=depth, r=hole_4mm_bolt_r, center = c);
}

module base_plate_container(){

  side_offset = 2.5;
  internal_height = 13;

  // main flat bottom plate
  translate(base_outer_position) cube([bp_edge_t,base_outer_size[1],base_outer_size[2] + buttress_t + ra_depth]);

  // add lower center of internals to get part of tabs and thickened middle plate

  internal_plate_pos  = [base_outer_position[0], 0, side_offset];
  internal_plate_size = [internal_height,psu_width - ledge_width - 0.01, psu_height - 2*side_offset];

  translate(internal_plate_pos) cube(internal_plate_size);

}

//**********

module shim(){

  shim_pos = [base_psu_overlap-shim_base_depth, -shim_thickness, (base_outer_size[2] - shim_width)/2-side_wall_t];
  shim_size = [shim_height, shim_thickness, shim_width];

  psu_hole1_pos = [ psu_frame_hole1_x, -shim_thickness, psu_height - psu_frame_hole_edge];
  psu_hole2_pos = [ psu_frame_hole2_x, -shim_thickness, psu_height - psu_frame_hole_edge];

  frame_hole1_pos = [base_outer_position[0] + y_hole1_x, 0, y_hole_z];
  frame_hole2_pos = [base_outer_position[0] + y_hole2_x, 0, y_hole_z];

  frame_hole1_rot = [90,0,0];
  frame_hole2_rot = [90,0,0];
  
  difference(){
    translate(shim_pos) cube(shim_size);

    psu_bolt_hole(psu_hole1_pos);
    psu_bolt_hole(psu_hole2_pos);

    shim_hole_with_nut(frame_hole1_pos,frame_hole1_rot);
    shim_hole_with_nut(frame_hole2_pos,frame_hole2_rot);
  }
}

module shim_hole_with_nut(pos,rot){

  translate(pos) rotate(rot) cylinder(r=2.1,h=shim_thickness);

  translate(pos) rotate(rot) cylinder(r=4,h=3, $fn=6);

}

module psu_bolt_hole(pos){

  head_d = 8;
  head_t = 3;
    
  translate(pos) rotate([-90,0,0]) bolt_hole_4mm(shim_thickness);
  translate(pos) rotate([-90,0,0]) cylinder(h=head_t,r=head_d/2,$fn=20);

}