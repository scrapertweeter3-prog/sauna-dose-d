# sauna-dose

Library docs for sauna-dose, a D package that treats a sauna protocol as
a dose with a floor, a decay curve, and a scheduling gate. The repo README
carries the worked protocol; this page reads the ledger the same way the
[sauna cardiovascular protocol guide](https://hackedself.com) does: what
a week of sessions actually banks, what survives when sessions lapse, and
what the calendar has to absorb.

## What a protocol banks

`thermalMinutesPerWeek(sessions, minutes)` is the weekly dose everything
else keys off. The protocol tier runs four 20-minute sessions at 178 F,
which is 80 thermal minutes a week. `meetsMinimumDose` checks the whole
floor at once: four or more sessions, fifteen or more minutes each, at or
above 175 F. The two-session week at 150 F fails on every axis, and a 135 F infrared
cabin sits below the line because that class of cabin tops out inside
the 120-to-150 band, where the adaptation stimulus never arrives.

The annual price of the passing tier is calendar arithmetic:
`equivalenceYearHours(80.0)` = 69.33 hours across
`annualSessionCount(4.0)` = 208 sessions. A protocol is a recurring
appointment, and the year figure is what a calendar actually holds.

## What lapsing costs

`acclimationWeeks(targetPercent, weeklyGainPercent)` prices the ramp.
Plasma volume gains of 4 to 15 percent show up inside the first two
weeks of regular exposure; taking the middle of that range as a weekly
gain rate near 9.5 percent, a target of +12 percent clears in 2 weeks.
The mirror side is
`plasmaVolumeRemaining(startPercent, weeksBelowThreshold)`, which decays
the held gain at roughly 85 percent retention a week once sessions drop
below the four-session floor: the +12 percent gain is 10.2 after one
lapsed week, 8.67 after two, 7.37 after three. The floor decides the decay: below it, the weekly
count stops holding the gain.

## The two gates around the session

Rehydration follows the 150 percent rule: `rehydrationOunces(2.0)` = 48 oz
of fluid for a 2-pound weigh-in loss, sodium included before bed. The
sleep gate is `latestStartBeforeBed(minutes, bufferMinutes)`: a
20-minute session has to begin at least 110 minutes ahead of bedtime to
preserve the 90-minute core-temperature buffer. Both numbers bound the same session
from either side: what goes back in afterward, and when the session has
to end for sleep to stay clean.

## Reproduce the numbers

```
dub run --config=demo
```

prints the full ledger: the tier line, the floor check, the annual hours,
the acclimation weeks, the three-week decay table, both infrared checks,
and both gates. The decay figures come from the same functions:

```d
import saunadose;

auto held2 = plasmaVolumeRemaining(12.0, 2);  // 8.67
auto weeks = acclimationWeeks(12.0, 9.5);     // 2
auto latest = latestStartBeforeBed(20.0);     // 110
```

`dub test` checks every figure against the library's unittests, including
the 80-minute week, the 69.33-hour year, the 85-percent weekly retention,
and the 110-minute latest start.

## Where the full protocol lives

The complete dose audit, session-by-session, sits in the sauna
cardiovascular protocol guide on [HackedSelf](https://hackedself.com).
