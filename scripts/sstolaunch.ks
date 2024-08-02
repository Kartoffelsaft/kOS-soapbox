list engines in engs.

set engAtmospheric to List().
set engVacuumatic to List().

for eng in engs {
    if (not eng:tag:contains("NOLAUNCH")) {
        if (eng:consumedResources:haskey("Intake Air")) {
            engAtmospheric:add(eng).
        } else {
            engVacuumatic:add(eng).
        }.
    }.
}.

print "Atmospheric engines: " + engAtmospheric.
print "Vacuumatic  engines: " + engVacuumatic.

lock throttle to 1.0.
lock steering to heading(90, 0).

for eng in engAtmospheric {
    eng:activate().
}.

wait until velocity:surface:mag > 100.

lock steering to heading(90, 5).
wait until altitude > 80.

gear off.

set pitch to 5.

lock steering to heading(90, pitch).

lock vertSpeed to vdot(velocity:surface, up:vector).
set lastPitchTrigger to time:seconds.

function updatePitch {
    parameter delta.

    set pitch to pitch + delta.
    print "Current Goal Pitch: " + pitch at (0, 0).
    set lastPitchTrigger to time:seconds.
}.

set pitchAdjustment to true.
clearscreen.

when lastPitchTrigger + 1 < time:seconds and vertSpeed < 0 then {
    if (pitchAdjustment) { updatePitch(-vertSpeed * 0.2). }.

    return pitchAdjustment.
}.

when lastPitchTrigger + 1 < time:seconds and vertSpeed > 3 then {
    if (pitchAdjustment) { updatePitch(- (vertSpeed - 3) * 0.1). }.

    return pitchAdjustment.
}.

function maximizeVelocity {
    parameter accThreshold.
    parameter velThreshold.

    wait until velocity:surface:mag > velThreshold.

    declare local v1 to velocity:surface. declare local t1 to time:seconds.
    wait 0.05.
    local lock v2 to velocity:surface. local lock t2 to time:seconds.
    local lock a to (v2 - v1)/(t2 - t1).

    until vdot(a, facing:vector) < accThreshold {
        set v1 to v2.
        set t1 to t2.

        wait 0.3.
    }.
}

maximizeVelocity(1.5, 250).

set newmode to false.
for eng in engAtmospheric {
    if (eng:multimode) {
        set newmode to true.
        eng:togglemode().
    }.
}.

if (newmode) { maximizeVelocity(5.5, 900). }.

set oldRollControlAngleRange to SteeringManager:rollControlAngleRange.
set SteeringManager:rollControlAngleRange to 50.
set SteeringManager:rollTorqueFactor to 2.5.

set pitchAdjustment to false.
from {local pitchup is pitch. lock steering to heading(90, pitchup).} 
until pitchup > 40 
step {set pitchup to pitchup + 0.2.} do {
    if (SteeringManager:rollError > 1.5) {
        set pitchup to pitchup - 0.2.
    } 

    wait 0.2.
}.

set SteeringManager:rollControlAngleRange to oldRollControlAngleRange.
wait until altitude > 15000.

for eng in engVacuumatic {
    eng:activate().
}.

unlock throttle.
set throttle to 1.0.

set throttleAdjustment to true.

set  s1 to vdot(velocity:orbit, up:vector). set  t1 to time:seconds.
wait 0.1.
lock s2 to vdot(velocity:orbit, up:vector). lock t2 to time:seconds.
lock vertAccel to (s2 - s1) / (t2 - t1).

when vertAccel > 0.5 then {
    set throttle to throttle - 0.05.

    return throttleAdjustment.
}.

when vertAccel < 0.0 then {
    set throttle to throttle + 0.05.

    return throttleAdjustment.
}.

until apoapsis > 75000 {
    set s1 to s2.
    set t1 to t2.

    wait 0.05.
}.

set throttleAdjustment to false.
set throttle to 0.0.
wait 0.1.
set throttle to 0.0.

lock steering to prograde.

wait until altitude > 70000.

add node(time:seconds + obt:eta:apoapsis, 0, 0, 1).
set thrustDir to nextnode:burnvector:direction + R(0, 0, 90).
lock steering to thrustDir.
remove nextnode.

set totalThrust to 0.
for eng in engVacuumatic {
    set totalThrust to totalThrust + eng:maxthrust.
}.

declare velgoal to sqrt(body:mu / (body:radius + apoapsis)).
declare thrustTime to (velgoal - velocity:orbit:mag) * ship:mass / totalThrust.

wait until obt:eta:apoapsis < thrusttime/2.

lock throttle to 1.0.

wait until periapsis > 70100. 

lock throttle to 0.0.

if core:bootfilename = "/boot/sstolaunch.ks" {
    set core:bootfilename to "".
}.
