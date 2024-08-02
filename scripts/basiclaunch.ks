declare orbitgoal to 74000.
declare threshold to 3000.

declare local countdown to 3.
until countdown < 0 {
    print countdown.
    wait 1.0.
    set countdown to countdown-1.
}.

when maxthrust = 0 then {
    print "stage".
    stage.
    print "new max thrust: " + maxthrust.
    wait 0.3.
    preserve.
}.

function raiseap {
    lock throttle to 1.0.
    declare local appct to ship:apoapsis / orbitgoal.
    lock steering to heading(90, 90 - 90 * appct).
}.

until ship:apoapsis > orbitgoal + threshold {
    raiseap().

    wait 0.02.
}.

lock throttle to 0.0.

when ship:apoapsis < orbitgoal then {
    raiseap().
    wait until ship:apoapsis > orbitgoal + threshold.
    lock throttle to 0.0.

    preserve.
}.

lock steering to "kill".

wait until ship:altitude > orbitgoal.

declare rad to body:radius + orbitgoal.
declare gravatap to body:mu / (rad * rad).
declare velgoal to sqrt(gravatap * rad).
declare dvneed to velgoal - ship:velocity:orbit:mag.
declare thrusttime to ship:mass * dvneed / ship:maxthrust.

clearscreen.
print "r: " + rad.
print "gravatap: " + gravatap.
print "velgoal: " + velgoal.
print "dvneed: " + dvneed.
print "thrusttime: " + thrusttime.

function apPrograde {
    add node(time:seconds + obt:eta:apoapsis, 0, 0, 1).
    set prg to nextnode:burnvector:direction + R(0, 0, 90).
    remove nextnode.
    return prg.
}.

wait until ship:orbit:eta:apoapsis < thrusttime/2.

until ship:periapsis > orbitgoal {
    lock steering to apPrograde.

    if ship:orbit:eta:apoapsis < thrusttime/2
    or ship:orbit:eta:periapsis < ship:orbit:eta:apoapsis {
        lock throttle to 1.0.
    } else { lock throttle to 0.0. }.

    wait 0.02.
}.

lock throttle to 0.0.

lock steering to facing.
unlock throttle.
unlock steering.

if core:bootfilename = "/boot/basiclaunch.ks" {
    set core:bootfilename to "".
}.

reboot.
