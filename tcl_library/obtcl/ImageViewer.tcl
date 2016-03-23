# ImageViewer.tcl --
#
#       This file implements the Tcl code for ...
#
#   Copyright 1998 Centre de Recherche Paul Pascal, Bordeaux, France.
#   Written by Nicolas Decoster.
#
#  RCS : $Id: ImageViewer.tcl,v 1.2 1998/07/31 17:02:03 decoster Exp $
#

class ImageViewer
ImageViewer inherit SmurfViewer

ImageViewer method init args {
    instvar special extr currentImage x y val k old_color zoom size_x size_y
    instvar first_box_corner_x first_box_corner_y
    instvar last_box_corner_x last_box_corner_y

    next

    puts $self

    set special ""
    set extr ""
    set val ""
    set k ""
    set x ""
    set y ""
    set old_color ""
    set currentImage ""
    set first_box_corner_x -1
    set first_box_corner_y -1
    set last_box_corner_x -1
    set last_box_corner_y -1

    set zoom 1

    #	Image $self
    #set currentImage b
    # on prend le premier element de la liste args
    set currentImage [lindex $args 0]

    # lrange renvoit une liste d'elements de args contenus
    # entre les indices 1 et la fin de args (les indices
    # commencent a zero)
    eval set extr [lrange $args 1 end]

    set size_x [im_size $currentImage]
    set size_y [im_size $currentImage -y]
    set special $currentImage

    eval iconvert $currentImage $self.viewer.content -zoom $zoom $extr -pos $x $y
    $self.viewer content $self.viewer.content

    #	button $self.tools.goto -text "Goto" \
	    #-command "GotoWidget g$self -parent_name $self"
    #pack $self.tools.goto -side left -padx 1m -pady 1m

    # Display ---------------------------------

    #	label $self.display.name -fg blue3 -text $currentImage
    #	pack  $self.display.name -side top -padx 1m -pady 1m

    frame $self.display.val
    pack  $self.display.val -fill x -side top
    label $self.display.val.msg -fg blue3 -text $currentImage
    label $self.display.val.val -fg green4 -relief sunken \
	    -bd 1 -width 13 -anchor e
    pack  $self.display.val.msg \
	    -side left -padx 1m -pady 1
    pack  $self.display.val.val \
	    -side right -padx 1m -pady 1
    #	pack  $self.display.val.msg $self.display.val.val \
	    -side left -padx 1m -pady 1m
    
    frame $self.display.xy
    pack  $self.display.xy -fill x -side top
    label $self.display.xy.msg -text "x y"
    label $self.display.xy.x -fg green4 -relief sunken \
	    -bd 1 -width 5 -anchor e
    label $self.display.xy.y -fg green4 -relief sunken \
	    -bd 1 -width 5 -anchor e
    pack  $self.display.xy.msg \
	    -side left -padx 1m -pady 1
    pack  $self.display.xy.y \
	    -side right -padx 1m -pady 1
    pack  $self.display.xy.x \
	    -side right -padx 8 -pady 1

    frame $self.display.spec
    pack  $self.display.spec -fill x -side top
    label $self.display.spec.msg -text $special
    label $self.display.spec.val -fg green4 -relief sunken \
	    -bd 1 -width 13 -anchor e
    pack  $self.display.spec.msg \
	    -side left -padx 1m -pady 1
    pack  $self.display.spec.val \
	    -side right -padx 1m -pady 1
    #	pack  $self.display.spec.msg $self.display.spec.val \
	    -side left -padx 1m -pady 1

    # actions associees aux boutons
    bind $self.viewer <Down>      "$self down"
    bind $self.viewer <Up>        "$self up"
    bind $self.viewer <Right>     "$self right"
    bind $self.viewer <Left>      "$self left"
    bind $self.viewer <1>         "$self mouse_goto %x %y"

    bind $self.viewer <Control-1> "$self set_first_box_corner %x %y"
    bind $self.viewer <Control-3> "$self set_last_box_corner %x %y"

    bind $self.viewer <Control-Right>  "$self zoom_incr"
    bind $self.viewer <Control-Left>   "$self zoom_decr"
    bind $self.viewer <Control-Up>     "$self next_im"
    bind $self.viewer <Control-Down>   "$self prev_im"
    bind $self.viewer <Z>              "$self zoom_incr"
    bind $self.viewer <z>              "$self zoom_decr"

    #	bind $self.viewer <2>         "$self vcut %x"
    #	bind $self.viewer <3>         "$self icut %y"
    bind $self.viewer <Enter>     "focus $self.viewer"
    bind $self.viewer <Control-l> "$self refresh"
}

ImageViewer method next_im {} {
    instvar currentImage
    global ImLst ImIndex

    set l [llength $ImLst]

    incr ImIndex
    if {$ImIndex >= $l} {
	incr ImIndex -1
    } else {
	set currentImage [lindex $ImLst $ImIndex]
	$self refresh
    }
}

ImageViewer method prev_im {} {
    instvar currentImage
    global ImLst ImIndex

    incr ImIndex -1
    if {$ImIndex < 0} {
	incr ImIndex 1
    } else {
	set currentImage [lindex $ImLst $ImIndex]
	$self refresh
    }
}

ImageViewer method set_first_box_corner {pos_x pos_y} {
    instvar size_x size_y first_box_corner_x first_box_corner_y zoom

    $self my_plot
    set first_box_corner_x [expr round($pos_x/$zoom)]
    set first_box_corner_y [expr round($pos_y/$zoom)] 
    puts "first $first_box_corner_x $first_box_corner_y"
}

ImageViewer method set_last_box_corner {pos_x pos_y} {
    instvar size_x size_y last_box_corner_x last_box_corner_y zoom

    $self my_plot
    set last_box_corner_x [expr round($pos_x/$zoom)]
    set last_box_corner_y [expr round($pos_y/$zoom)] 
    puts "last $last_box_corner_x $last_box_corner_y"
}

ImageViewer method cut_box {new_name} {
}

ImageViewer method set_special {image} {
    instvar special x y

    set special $image
    $self.display.spec.msg configure -text $special 
    if {$x != "" && $y != ""} {
	set spec_val [value $special $x $y]
	$self.display.spec.val   configure -text "[set spec_val]" 
    }
}

ImageViewer method set_image {image} {
    instvar currentImage zoom extr x y

    set currentImage $image
    $self.display.val.msg configure -text $currentImage
    eval iconvert $currentImage $self.viewer.content -zoom $zoom $extr -pos $x $y
    $self.viewer content $self.viewer.content
    if {$x != "" && $y != ""} {
	$self display_val
    }
}

ImageViewer method refresh {} {
    instvar currentImage zoom x y extr

    eval iconvert $currentImage $self.viewer.content \
	    -zoom $zoom $extr -pos $x $y
}

ImageViewer method my_plot {{color ""}} {
    instvar currentImage zoom x y

    set option ""
    if {$color != ""} {
	set option "-color $color"
    }
    if {($x != "") || ($y != "")} {
	eval iplot $self.viewer.content $currentImage $x $y -zoom $zoom $option
	$self.viewer content $self.viewer.content
    }
}

ImageViewer method vcut {pos_x} {
    instvar currentImage zoom

    icut $currentImage sigcut -vertical [expr round($pos_x/$zoom)]
    saff sigcut "$currentImage : vertical [expr round($pos_x/$zoom)]"
}

ImageViewer method hcut {pos_y} {
    instvar currentImage zoom

    icut $currentImage sigcut -horizontal [expr round($pos_y/$zoom)]
    saff sigcut "$currentImage : horizontal [expr round($pos_y/$zoom)]"
}

ImageViewer method down {} {
    instvar size_x size_y x y

    if {$x != "" && $y != ""} {
	$self my_plot
	if { $y < [expr $size_y-1]} {incr y}
	$self display_val
	$self my_plot 2
    }
}

ImageViewer method up {} {
    instvar size_x size_y x y

    if {$x != "" && $y != ""} {
	$self my_plot
	if { $y > 0 } {incr y -1}
	$self display_val
	$self my_plot 2
    }
}

ImageViewer method right {} {
    instvar size_x size_y x y

    if {$x != "" && $y != ""} {
	$self my_plot
	if { $x < [expr $size_x-1]} {incr x}
	$self display_val
	$self my_plot 2
    }
}

ImageViewer method left {} {
    instvar size_x size_y x y

    if {$x != "" && $y != ""} {
	$self my_plot
	if { $x > 0} {incr x -1}
	$self display_val
	$self my_plot 2
    }
}

ImageViewer method mouse_goto {pos_x pos_y} {
    instvar size_x size_y x y zoom

    $self my_plot
    set x [expr round($pos_x/$zoom)]
    set y [expr round($pos_y/$zoom)] 
    $self display_val
    #	eval iconvert $currentImage $self.viewer.content -zoom $zoom $extr -pos $x $y
    $self my_plot 2
}

ImageViewer method mouse_motion {pos_x pos_y} {
    instvar x y zoom

    set x [expr round($pos_x/$zoom)]
    set y [expr round($pos_y/$zoom)] 
    $self display_val
}

ImageViewer method goto {pos_x pos_y} {
    instvar x y 

    $self my_plot
    set x $pos_x
    set y $pos_y 
    $self display_val
    #eval iconvert $currentImage $self.viewer.content -zoom $zoom $extr -pos $x $y
    $self my_plot 2
}

ImageViewer method display_val {} {
    instvar currentImage x y special val

    set val [value $currentImage $x $y]
    set spec_val [value $special $x $y]
    $self.display.xy.x   configure -text "[set x]" 
    $self.display.xy.y   configure -text "[set y]" 
    $self.display.val.val configure -text "[set val]" 
    $self.display.spec.val   configure -text "[set spec_val]" 
}

ImageViewer method zoom_incr {} {
    instvar zoom currentImage extr x y

    if { [set zoom] < 6 } {
	incr zoom 
	eval iconvert $currentImage $self.viewer.content -zoom $zoom $extr -pos $x $y
    }
}
ImageViewer method zoom_decr {} {
    instvar zoom currentImage extr x y

    if { [set zoom] > 1 } {
	incr zoom -1
	eval iconvert $currentImage $self.viewer.content -zoom $zoom $extr -pos $x $y
    }
}

ImageViewer method zoom {new_zoom} {
    instvar zoom currentImage extr x y

    set zoom $new_zoom
    if {$zoom > 6} {set zoom 6}
    if {$zoom < 1} {set zoom 1}
    eval iconvert $currentImage $self.viewer.content -zoom $zoom $extr -pos $x $y
}

# iaff --
# usage : iaff image args
#
#  Display an image.
#
# Parameters :
#   image      - 
#                
#   args       - args, options...see help message of iconvert define by
#                ViewConvImageCmd_ in widgets/ConvIma.c !!!
#
# soon there will be a real help message for this.
#
# Return value :
#   The name of the object that manage this ViewImage window.
#
# Example :
#   iaff ima -ext ei
#   This command line open a window that displays image "ima" and 
# simultaneously the ExtImage "ei"

proc iaff  {image args} {
    global viewNb

    toplevel .v$viewNb
    ImageViewer .v$viewNb.iv $image $args
    pack .v$viewNb.iv
    bind .v$viewNb <c> "destroy .v$viewNb"
    incr viewNb
}
