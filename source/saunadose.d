/** Sauna dose-response arithmetic: the weekly thermal-minutes ledger behind
    a cardiovascular sauna protocol. The adaptation floor is four sessions a
    week at or above 175 degrees Fahrenheit, 15 to 20 minutes each; below it,
    plasma-volume gains decay week over week. Prices the time cost, the
    acclimation ramp, the detraining decay, the 150 percent rehydration rule,
    and the pre-bed scheduling gate. Temperatures are degrees Fahrenheit;
    weeks are 7-day weeks. */
module saunadose;

/// Thermal minutes a week of protocol actually banks: sessions * minutes.
double thermalMinutesPerWeek(double sessions, double minutes) @safe pure {
    return sessions * minutes;
}

/// A weekly dose clears the published adaptation floor: at least 4 sessions,
/// each 15+ minutes, at or above the 175 F thermal stimulus threshold.
bool meetsMinimumDose(double sessions, double minutes, double tempF)
@safe pure {
    return sessions >= 4.0 && minutes >= 15.0 && tempF >= 175.0;
}

/// Hours a fixed weekly protocol costs over a year: minutes * 52 / 60, the
/// same calendar block spent on anything else.
double equivalenceYearHours(double minutesPerWeek) @safe pure {
    return minutesPerWeek * 52.0 / 60.0;
}

/// Weeks of consistent exposure to reach a plasma-volume gain target
/// (percent), given a weekly gain rate in percent.
int acclimationWeeks(double targetPercent, double weeklyGainPercent)
@safe pure {
    if (weeklyGainPercent <= 0) return 0;
    import std.math : ceil;
    return cast(int) ceil(targetPercent / weeklyGainPercent);
}

/// Plasma-volume gain (percent points) still held after weeksBelowThreshold
/// weeks under 4 sessions per week: gains contract about 15 percent a week.
double plasmaVolumeRemaining(double startPercent, int weeksBelowThreshold,
    double weeklyRetain = 0.85) @safe pure {
    double held = startPercent;
    foreach (_; 0 .. weeksBelowThreshold) held *= weeklyRetain;
    return held;
}

/// An infrared cabin at tempF sits below the thermal stimulus threshold
/// (they run 120 to 150 F) and may never reach the adaptation window.
bool infraredUnderThreshold(double tempF) @safe pure {
    return tempF < 175.0;
}

/// Fluid replacement in ounces after a weigh-in sweat loss in pounds: the
/// 150 percent rule at 16 oz per pound.
double rehydrationOunces(double sweatLossLbs) @safe pure {
    return sweatLossLbs * 16.0 * 1.5;
}

/// Latest session start, in minutes before bed, that still finishes a
/// minutes-long session with the 90-minute core-temperature buffer.
double latestStartBeforeBed(double minutes, double bufferMinutes = 90.0)
@safe pure {
    return minutes + bufferMinutes;
}

/// Sessions a year of a fixed weekly dose adds up to: the annual commitment
/// behind the protocol decision.
int annualSessionCount(double sessionsPerWeek) @safe pure {
    return cast(int) (sessionsPerWeek * 52.0 + 0.5);
}

unittest {
    import std.math : approxEqual;

    // The minimum adaptation dose: 4 sessions x 20 minutes = 80 thermal
    // minutes a week; over a year that block costs 69.33 hours.
    assert(approxEqual(thermalMinutesPerWeek(4.0, 20.0), 80.0));
    assert(approxEqual(equivalenceYearHours(80.0), 69.33, 1e-6, 0.01));
    assert(annualSessionCount(4.0) == 208);

    // The dose gate: protocol tier passes, casual use fails.
    assert(meetsMinimumDose(4.0, 20.0, 178.0));
    assert(meetsMinimumDose(5.0, 15.0, 175.0));
    assert(!meetsMinimumDose(3.0, 25.0, 180.0));
    assert(!meetsMinimumDose(4.0, 20.0, 150.0));

    // Acclimation ramp at the mid-point 9.5%/week of the published 4-15%
    // expansion range: +12% takes 2 weeks, +5% takes 1.
    assert(acclimationWeeks(12.0, 9.5) == 2);
    assert(acclimationWeeks(5.0, 9.5) == 1);

    // Detraining: a +12% gain held at 85%/week under the 4-session floor
    // leaves 10.2 points after 1 week, 8.7 after 2.
    assert(approxEqual(plasmaVolumeRemaining(12.0, 1), 10.2, 1e-6, 0.01));
    assert(approxEqual(plasmaVolumeRemaining(12.0, 2), 8.67, 1e-6, 0.01));

    // Infrared cabins at 135 F sit below the stimulus threshold.
    assert(infraredUnderThreshold(135.0));
    assert(!infraredUnderThreshold(180.0));

    // The 150 percent rehydration rule: 2 lb of sweat loss = 48 oz.
    assert(approxEqual(rehydrationOunces(2.0), 48.0));

    // Sleep gate: a 20-minute session with the 90-minute buffer must start
    // 110 minutes before bed at the latest.
    assert(approxEqual(latestStartBeforeBed(20.0), 110.0));
}
