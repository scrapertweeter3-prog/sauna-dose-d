import saunadose;
import std.stdio;

void main() {
    writeln("Sauna dose ledger (floor: 4 sessions/wk, 15-20 min, 175 F)");
    writeln("---------------------------------------------------------");

    const tierSessions = 4.0, tierMinutes = 20.0, tierTemp = 178.0;
    const weekMinutes = thermalMinutesPerWeek(tierSessions, tierMinutes);
    writefln!"protocol tier        : %s sessions x %s min @ %s F = %s thermal min/wk"(
        tierSessions, tierMinutes, tierTemp, weekMinutes);
    writefln!"clears minimum dose  : %s"(meetsMinimumDose(tierSessions,
        tierMinutes, tierTemp));
    writefln!"annual time cost     : %s hours over %s sessions"(
        equivalenceYearHours(weekMinutes), annualSessionCount(tierSessions));

    const casual = meetsMinimumDose(2.0, 20.0, 150.0);
    writefln!"casual 2x@150F tier  : passes floor? %s"(casual);

    writefln!"acclimation to +12%%  : %s weeks at ~9.5%%/week"(
        acclimationWeeks(12.0, 9.5));

    writeln("below the 4-session floor (85%/wk retention):");
    foreach (weeks; 1 .. 4) {
        writefln!"  week %s -> %s%% of the +12%% gain still held"(
            weeks, plasmaVolumeRemaining(12.0, weeks));
    }

    writeln("infrared check:");
    writefln!"  135 F cabin under 175 F threshold: %s"(
        infraredUnderThreshold(135.0));
    writefln!"  180 F cabin under 175 F threshold: %s"(
        infraredUnderThreshold(180.0));

    writefln!"rehydration, 2 lb loss: %s oz (150%% rule)"(
        rehydrationOunces(2.0));
    writefln!"latest start before bed for a 20-min session: %s min"(
        latestStartBeforeBed(20.0));
}
