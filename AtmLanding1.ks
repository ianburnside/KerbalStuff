// For controlled atmospheric landing to specified target for a blunt capsule with an offset center of mass to create lift.

clearscreen.

global acc is v(0,0,0).
global lastVel is ship:velocity:orbit.
global lastTime is time:seconds.
when true then {
    local dt is time:seconds - lastTime.
    if dt > 0 {
        set acc to (ship:velocity:orbit - lastVel) / dt.
    }
    set lastTime to time:seconds.
    set lastVel to ship:velocity:orbit.
    return true.
}

main().

function main {
    print "Waiting until atmosphere...".
    // SetLandingSite().
    // TimeUntilAtmosphere().
    // YawPitchRollOrient().
    // ProjectedLandingSiteIfUp().
    // ProjectedLandingSiteIfDown().
    ///InitialAttitude().
    //InAtmosphere().
    //IsCaptured().
    // RollOrient().
    //CheckRollAngle().
    //print getroll(ship). //this works
    roll_to(-45).
    //count_test().
    //angle_to_sp(-45). //this works
    //print roll_rate. //this works
}

function count_test {
    set t0 to time:seconds.
    print "Time 1: " + t0.
    wait 5.
    set t1 to time:seconds.
    print "Time 2: " + t1.
    print time:seconds - t0.
}

function getroll { //This works! Don't touch it, you! 
  parameter ves.
  
  if vang(ship:facing:vector,ship:up:vector) < 0.2 { //this is the dead zone for roll when the ship is vertical
    return 0.
  } else {
    local raw is vang(vxcl(ship:facing:vector,ship:up:vector), ves:facing:starvector).
    if vang(ves:up:vector, ves:facing:topvector) > 90 {
      if raw > 90 {
        return 270 - raw.
      } else {
        return -90 - raw.
      }
    } else {
      return raw - 90. //A roll of 0 is the capsule facing upright.
    }
  } 
}.

function getroll360 { //This works! Don't touch it, you! The roll angle is from 0-360.
    if getroll(ship) < 0 {return 360 + getroll(ship).}
    else {return getroll(ship).}
}.

function roll_rate { //This works! Don't touch it, you! 
    set t0 to time:seconds. 
    set roll0 to getroll(ship).
    wait .0001.
    local dt is time:seconds - t0.

    return (getroll(ship) - roll0) / (dt).
}

function roll_null {
    //nulls the roll
    //if roll_rate
}

function angle_to_sp {
    parameter roll_sp. //input is in the form of: 0 is up. -90 is left, 90 is right. -180/180 is down.
    set roll_start to getroll(ship).
    if roll_start < 0 {set roll_start to 360 + roll_start.} //this converts the angle to 0-360, where 0->0/360, 90->90, -180/180->180, and -90->270. 
    if roll_sp < 0 {set roll_sp to 360 + roll_sp.} //this does the same here, angle is now from 0-360.

    if roll_sp < roll_start { //determines the counter clockwise (CCW) and clockwise (CW) angle to set point.
        set angleCCW to roll_start - roll_sp.
        set angleCW to 360 + roll_sp - roll_start.
        } else {
        set angleCCW to roll_start - roll_sp + 360.
        set angleCW to roll_sp - roll_start.
        }
        if angleCW < angleCCW
        {return angleCW.} else
        {return angleCCW.}
}

function roll_to {
    SAS off.
    RCS on.
    parameter roll_sp. //input is in the form of: 0 is up. -90 is left, 90 is right. -180/180 is down.
    set roll_start to getroll(ship).
    if roll_start < 0 {set roll_start to 360 + roll_start.} //this converts the angle to 0-360, where 0->0/360, 90->90, -180/180->180, and -90->270. 
    if roll_sp < 0 {set roll_sp to 360 + roll_sp.} //this does the same here, angle is now from 0-360.

    // print roll_start.
    // print roll_sp.

    if roll_sp < roll_start { //determines the counter clockwise (CCW) and clockwise (CW) angle to set point.
        set angleCCW to roll_start - roll_sp.
        set angleCW to 360 + roll_sp - roll_start.
        } else {
        set angleCCW to roll_start - roll_sp + 360.
        set angleCW to roll_sp - roll_start.
        }
        // print angleCCW.
        // print angleCW.
 
    set roll_rate_max to 15.
    set roll_mod_max to 30.
    set roll0 to getroll360().
    set rollrate0 to roll_rate.
    set t0 to time:seconds.
    wait .0001.

    print "Roll setpoint: " + roll_sp.
    print "Roll currently: " + getroll(ship).
    print "Roll Rate 1: " + roll_rate.
    print "Time 1: " + t0.
    print "Counter clockwise: " + angleCCW.
    print "Clockwise: " + angleCW.
    print "  ".
    print "------------------".
    if angleCCW < angleCW { //roll CCW, since CCW is the shortest angle to set point.
        set angle0 to angleCCW.
        //set roll_rate0 to abs(roll_rate).
        if angleCCW < roll_mod_max {set imp_mod to angleCCW/roll_mod_max.} else {set imp_mod to 1.} //modifies the impulse if there is a small angle to the setpoint
        set ship:control:roll to -1 * imp_mod. //roll direction is correct, negative is CCW
        wait until abs(roll_rate) > roll_rate_max or angleCCW < angle0/2.
            set ship:control:roll to 0.
            local dt is time:seconds - t0.
            set roll_acc to (rollrate0 - roll0) / dt.
            set roll_delta to abs(getroll360() - roll0).
            print "Counter clockwise! It ran the first one!".
            print "------------------".
            print "Counter clockwise: " + angleCCW.
            print "Roll Delta: " + roll_delta.
            print "Roll Rate 2: " + roll_rate.
            print "Roll Acc: " + roll_acc.
            print "Time 1: " + time:seconds.
            print "Delta Time: " + dt.
            if getroll360() < roll_sp
            {set ang_mod to 360.} else {set ang_mod to 0.}
            print "Ang Mod: " + ang_mod.
        when angle_to_sp(roll_sp) < 5.2 then { // + roll_delta
            set ship:control:roll to 1 * imp_mod.
            print "it's slowing...".
            print "Roll: " + getroll360().
            print "------------------".
        when roll_rate > 0 then {
            set ship:control:roll to 0.
            print "it stopped".
            print "Roll: " + getroll360().
            }.
            }.
        
    } else { //roll CW, since CW is the shortest angle to set point.
        set angle0 to angleCW.
        //set roll_rate0 to abs(roll_rate).
        if angleCW < roll_mod_max {set imp_mod to angleCW/roll_mod_max.} else {set imp_mod to 1.} //modifies the impulse if there is a small angle to the setpoint
        set ship:control:roll to 1. //roll direction is correct
        wait until abs(roll_rate) > roll_rate_max or angleCW < angle0/2.
            set ship:control:roll to 0.
            local dt is time:seconds - t0.
            set roll_acc to (rollrate0 - roll0) / dt.
            set roll_delta to abs(getroll360() - roll0).
            print "Clockwise! It ran the second one!".
            print "------------------".
            print "Clockwise: " + angleCW.
            print "Roll Delta: " + roll_delta.
            print "Roll Rate 2: " + roll_rate.
            print "Roll Acc: " + roll_acc.
            print "Time 1: " + time:seconds.
            print "Delta Time: " + dt.
            if getroll360() < roll_sp
            {set ang_mod to 360.} else {set ang_mod to 0.}
            print "Ang Mod: " + ang_mod.
        when angle_to_sp(roll_sp) < 5.2 then { // + roll_delta
            set ship:control:roll to -1.
            print "it's slowing...".
            print  "Roll: " + getroll360().
            print "------------------".   
        when roll_rate < 0 then {
            set ship:control:roll to 0.
            print "it stopped".
            //print abs(getroll(ship)).
            print  "Roll: " + getroll360().
            }.
            }.   
        //set ship:control:roll to -1.
        //wait until abs(roll_rate) < 0.
        //set ship:control:roll to 0.
    }
    wait 12.
    //fine tune.
    //roll_null().
}


function InitialAttitude {
    wait until ship:altitude < body:atm:height + 10000..
    print "Orienting capsule for atmosphere...".
    SAS off.
    RCS on.
    lock STEERING to retrograde.
    wait until ship:altitude < body:atm:height.
    unlock STEERING.
    return True.
}

function InAtmosphere {
    // InAtmosphere() function
    // Check if current altitude is < atmosphere height
    // Return True when condition met
    wait until ship:altitude < body:atm:height..
    print "In atmosphere. Running re-entry program.".
    print "Velocity: " + ship:velocity:orbit:mag + " m/s".
    //lock target:roll to 45.
    return True.
}

function IsCaptured {
    // IsCaptured() function
    // Check if deceleration > 2.5G (2.5*9.81)
    // Return True when condition met
    // TODO: Possibly use derivative/integral PID if entering at a shallower angle to end later
    // TODO: Possibly use derivative/integral PID if entering at a steeper angle to end earlier
    wait until velocity:orbit:mag < 2100.
    print "Capture confirmed".
    return True.
}

function RollRight {
    SAS off.
    RCS on.
    set ship:control:roll to .2.
    //wait until 
}

// ROTATEFROMTO(fromVec,toVec)

function RollLleft {
    LOCK STEERING TO V(0,87,15).
}