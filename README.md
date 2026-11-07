# sauna-dose

Sauna dose-response arithmetic in pure D functions over the standard library.
A sauna protocol is a dose, not a vibe: the published adaptation floor is
four sessions a week at or above 175 degrees Fahrenheit, 15 to 20 minutes
each, and every number that matters is weekly thermal minutes, decay rates,
and scheduling buffers. This library prices them.

## The functions

- `thermalMinutesPerWeek(sessions, minutes)` - the dose a protocol actually
  banks each week.
- `meetsMinimumDose(sessions, minutes, tempF)` - the floor check: 4+
  sessions, 15+ minutes each, at or above the 175 F stimulus threshold.
- `equivalenceYearHours(minutesPerWeek)` - the yearly calendar cost of a
  fixed weekly dose.
- `acclimationWeeks(targetPercent, weeklyGainPercent)` - weeks of consistent
  exposure to reach a plasma-volume target.
- `plasmaVolumeRemaining(startPercent, weeksBelowThreshold, weeklyRetain)` -
  gain still held under the 4-session floor, decaying about 15 percent a
  week.
- `infraredUnderThreshold(tempF)` - infrared cabins run 120 to 150 F and may
  never reach the adaptation window.
- `rehydrationOunces(sweatLossLbs)` - the 150 percent rehydration rule at
  16 oz per pound of weigh-in loss.
- `latestStartBeforeBed(minutes, bufferMinutes)` - the sleep gate: finish a
  session 90+ minutes before bed.
- `annualSessionCount(sessionsPerWeek)` - the yearly commitment behind the
  protocol decision.

## The worked protocol

The figures track the dose audit in the sauna cardiovascular protocol guide
on [HackedSelf](https://hackedself.com):

- Minimum adaptation dose: 4 sessions x 20 minutes = 80 thermal minutes a
  week. That block costs 69.33 hours a year across 208 sessions.
- Acclimation: plasma volume expands 4 to 15 percent within one to two weeks
  of consistent exposure; at the range mid-point (about 9.5 percent a week)
  a +12 percent target lands in 2 weeks.
- Detraining: drop below the 4-session floor and the +12 percent gain
  contracts at roughly 85 percent retention a week, leaving 10.2 points
  after one week and 8.7 after two.
- Casual use fails the gate: 2 relaxed sessions a week at 150 F sits under
  every threshold, and infrared cabins at 120 to 150 F may never reach the
  stimulus window at all.
- Rehydration: a 2-pound weigh-in loss means 48 oz of fluid with sodium
  before bed.
- Sleep gate: a 20-minute session must start at least 110 minutes before
  bedtime to keep the 90-minute core-temperature buffer.

`dub test` reproduces every figure in that list; the demo config prints the
full ledger including the week-by-week decay table.

## Usage

```d
import saunadose;

auto held = plasmaVolumeRemaining(12.0, 2);
// held ~= 8.67
```

MIT licensed. DUB package: [sauna-dose](https://code.dlang.org/packages/sauna-dose).
