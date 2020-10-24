const std = @import("std");
const expectEqual = std.testing.expectEqual;

pub const YearInt = i19;
pub const OrdinalInt = u9;
pub const MonthInt = u4;
pub const DayInt = u5;

pub const MAX_YEAR = std.math.maxInt(YearInt);
pub const MIN_YEAR = std.math.minInt(YearInt);

pub const A = YearFlags{ .flags = 0o15 };
pub const AG = YearFlags{ .flags = 0o05 };
pub const B = YearFlags{ .flags = 0o14 };
pub const BA = YearFlags{ .flags = 0o04 };
pub const C = YearFlags{ .flags = 0o13 };
pub const CB = YearFlags{ .flags = 0o03 };
pub const D = YearFlags{ .flags = 0o12 };
pub const DC = YearFlags{ .flags = 0o02 };
pub const E = YearFlags{ .flags = 0o11 };
pub const ED = YearFlags{ .flags = 0o01 };
pub const F = YearFlags{ .flags = 0o17 };
pub const FE = YearFlags{ .flags = 0o07 };
pub const G = YearFlags{ .flags = 0o16 };
pub const GF = YearFlags{ .flags = 0o06 };

pub const YearFlags = packed struct {
    flags: u8,

    pub const MOD_400_TO_FLAGS = [400]YearFlags{
        BA, G,  F,  E,  DC, B,  A,  G,  FE, D,  C,  B,  AG, F,  E,
        D,  CB, A,  G,  F,  ED, C,  B,  A,  GF, E,  D,  C,  BA, G,
        F,  E,  DC, B,  A,  G,  FE, D,  C,  B,  AG, F,  E,  D,  CB,
        A,  G,  F,  ED, C,  B,  A,  GF, E,  D,  C,  BA, G,  F,  E,
        DC, B,  A,  G,  FE, D,  C,  B,  AG, F,  E,  D,  CB, A,  G,
        F,  ED, C,  B,  A,  GF, E,  D,  C,  BA, G,  F,
        E,  DC, B,  A,  G,  FE, D,  C,  B,  AG, F,  E,  D, // 100
        C,  B,  A,  G,  FE, D,  C,  B,  AG, F,  E,  D,  CB,
        A,  G,  F,  ED, C,  B,  A,  GF, E,  D,  C,  BA, G,
        F,  E,  DC, B,  A,  G,  FE, D,  C,  B,  AG, F,  E,
        D,  CB, A,  G,  F,  ED, C,  B,  A,  GF, E,  D,  C,
        BA, G,  F,  E,  DC, B,  A,  G,  FE, D,  C,  B,  AG,
        F,  E,  D,  CB, A,  G,  F,  ED, C,  B,  A,  GF, E,
        D,  C,  BA, G,  F,  E,  DC, B,  A,
        G,  FE, D,  C,  B,  AG, F,  E,  D,  CB, A,  G,  F, // 200
        E,  D,  C,  B,  AG, F,  E,  D,  CB, A,  G,  F,  ED,
        C,  B,  A,  GF, E,  D,  C,  BA, G,  F,  E,  DC, B,
        A,  G,  FE, D,  C,  B,  AG, F,  E,  D,  CB, A,  G,
        F,  ED, C,  B,  A,  GF, E,  D,  C,  BA, G,  F,  E,
        DC, B,  A,  G,  FE, D,  C,  B,  AG, F,  E,  D,  CB,
        A,  G,  F,  ED, C,  B,  A,  GF, E,  D,  C,  BA, G,
        F,  E,  DC, B,  A,  G,  FE, D,  C,
        B,  AG, F,  E,  D,  CB, A,  G,  F,  ED, C,  B,  A, // 300
        G,  F,  E,  D,  CB, A,  G,  F,  ED, C,  B,  A,  GF,
        E,  D,  C,  BA, G,  F,  E,  DC, B,  A,  G,  FE, D,
        C,  B,  AG, F,  E,  D,  CB, A,  G,  F,  ED, C,  B,
        A,  GF, E,  D,  C,  BA, G,  F,  E,  DC, B,  A,  G,
        FE, D,  C,  B,  AG, F,  E,  D,  CB, A,  G,  F,  ED,
        C,  B,  A,  GF, E,  D,  C,  BA, G,  F,  E,  DC, B,
        A,  G,  FE, D,  C,  B,  AG, F,  E,
        D, CB, A, G, F, ED, C, B, A, GF, E, D, C, // 400
    };

    pub fn from_year(year: i32) YearFlags {
        return from_year_mod_400(@intCast(usize, @mod(year, 400)));
    }

    pub fn from_year_mod_400(year: usize) YearFlags {
        return MOD_400_TO_FLAGS[year];
    }

    pub fn ndays(this: @This()) u32 {
        return @as(u32, 366) - (this.flags >> 3);
    }

    pub fn nisoweeks(this: @This()) u32 {
        return 52 + ((@as(u32, 0b0000010000000110) >> @intCast(u5, this.flags)) & 1);
    }
};

test "year flags number of days from year" {
    expectEqual(@as(u32, 365), YearFlags.from_year(2014).ndays());
    expectEqual(@as(u32, 366), YearFlags.from_year(2012).ndays());
    expectEqual(@as(u32, 366), YearFlags.from_year(2000).ndays());
    expectEqual(@as(u32, 365), YearFlags.from_year(1900).ndays());
    expectEqual(@as(u32, 366), YearFlags.from_year(1600).ndays());
    expectEqual(@as(u32, 365), YearFlags.from_year(1).ndays());
    expectEqual(@as(u32, 366), YearFlags.from_year(0).ndays()); // 1 BCE (proleptic Gregorian)
    expectEqual(@as(u32, 365), YearFlags.from_year(-1).ndays()); // 2 BCE
    expectEqual(@as(u32, 366), YearFlags.from_year(-4).ndays()); // 5 BCE
    expectEqual(@as(u32, 365), YearFlags.from_year(-99).ndays()); // 100 BCE
    expectEqual(@as(u32, 365), YearFlags.from_year(-100).ndays()); // 101 BCE
    expectEqual(@as(u32, 365), YearFlags.from_year(-399).ndays()); // 400 BCE
    expectEqual(@as(u32, 366), YearFlags.from_year(-400).ndays()); // 401 BCE
}

test "year flags number of iso weeks" {
    expectEqual(@as(u32, 52), A.nisoweeks());
    expectEqual(@as(u32, 52), B.nisoweeks());
    expectEqual(@as(u32, 52), C.nisoweeks());
    expectEqual(@as(u32, 53), D.nisoweeks());
    expectEqual(@as(u32, 52), E.nisoweeks());
    expectEqual(@as(u32, 52), F.nisoweeks());
    expectEqual(@as(u32, 52), G.nisoweeks());
    expectEqual(@as(u32, 52), AG.nisoweeks());
    expectEqual(@as(u32, 52), BA.nisoweeks());
    expectEqual(@as(u32, 52), CB.nisoweeks());
    expectEqual(@as(u32, 53), DC.nisoweeks());
    expectEqual(@as(u32, 53), ED.nisoweeks());
    expectEqual(@as(u32, 52), FE.nisoweeks());
    expectEqual(@as(u32, 52), GF.nisoweeks());
}

pub const MIN_OL: u32 = 1 << 1;
pub const MAX_OL: u32 = 366 << 1; // larger than the non-leap last day `(365 << 1) | 1`
pub const MIN_MDL: u32 = (1 << 6) | (1 << 1);
pub const MAX_MDL: u32 = (12 << 6) | (31 << 1) | 1;

const XX: i8 = -128;
const MDL_TO_OL = [MAX_MDL + 1]i8{
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX,
    XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, XX, // 0
    XX, XX, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, // 1
    XX, XX, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66,
    66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66,
    66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66,
    66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, XX, XX, XX, XX, XX, // 2
    XX, XX, 72, 74, 72, 74, 72, 74, 72, 74, 72, 74, 72, 74, 72, 74,
    72, 74, 72, 74, 72, 74, 72, 74, 72, 74, 72, 74, 72, 74, 72, 74,
    72, 74, 72, 74, 72, 74, 72, 74, 72, 74, 72, 74, 72, 74, 72, 74,
    72, 74, 72, 74, 72, 74, 72, 74, 72, 74, 72, 74, 72, 74, 72, 74, // 3
    XX, XX, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76,
    74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76,
    74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76,
    74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76, XX, XX, // 4
    XX, XX, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80,
    78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80,
    78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80,
    78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80, // 5
    XX, XX, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82,
    80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82,
    80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82,
    80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82, XX, XX, // 6
    XX, XX, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86,
    84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86,
    84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86,
    84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86, // 7
    XX, XX, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88,
    86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88,
    86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88,
    86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, // 8
    XX, XX, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90,
    88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90,
    88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90,
    88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90, XX, XX, // 9
    XX, XX, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94,
    92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94,
    92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94,
    92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94, // 10
    XX, XX, 94, 96, 94, 96, 94, 96, 94, 96, 94, 96, 94, 96, 94, 96,
    94, 96, 94, 96, 94, 96, 94, 96, 94, 96, 94, 96, 94, 96, 94, 96,
    94, 96, 94, 96, 94, 96, 94, 96, 94, 96, 94, 96, 94, 96, 94, 96,
    94, 96,  94, 96,  94, 96,  94, 96,  94, 96,  94, 96,  94, 96,  XX, XX, // 11
    XX, XX,  98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98, 100,
    98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98, 100,
    98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98, 100,
    98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98,
    100, // 12
};

const OL_TO_MDL = [MAX_OL + 1]u8{
    0,  0, // 0
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, // 1
    66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66,
    66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66,
    66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66, 66,
    66, 66, 66, 66, 66, 66,
    66, 66, 66, 66, 66, 66, 66, 66, 66, // 2
    74, 72, 74, 72, 74, 72, 74, 72, 74,
    72, 74, 72, 74, 72, 74, 72, 74, 72,
    74, 72, 74, 72, 74, 72, 74, 72, 74,
    72, 74, 72, 74, 72, 74, 72, 74, 72,
    74, 72, 74, 72, 74, 72, 74, 72, 74,
    72, 74, 72,
    74, 72, 74, 72, 74, 72, 74, 72, 74, 72, 74, 72, 74, 72, // 3
    76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74,
    76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74,
    76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74,
    76, 74, 76, 74, 76, 74,
    76, 74, 76, 74, 76, 74, 76, 74, 76, 74, 76, 74, // 4
    80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78,
    80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78,
    80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78,
    80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78,
    80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78, 80, 78, // 5
    82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80,
    82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80,
    82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80,
    82, 80, 82, 80, 82, 80,
    82, 80, 82, 80, 82, 80, 82, 80, 82, 80, 82, 80, // 6
    86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84,
    86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84,
    86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84,
    86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84,
    86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84, 86, 84, // 7
    88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86,
    88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86,
    88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86,
    88, 86, 88, 86, 88, 86,
    88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, 88, 86, // 8
    90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88,
    90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88,
    90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88,
    90, 88, 90, 88, 90, 88,
    90, 88, 90, 88, 90, 88, 90, 88, 90, 88, 90, 88, // 9
    94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92,
    94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92,
    94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92,
    94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92,
    94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92, 94, 92, // 10
    96, 94, 96, 94, 96, 94, 96, 94, 96, 94, 96, 94, 96, 94,
    96, 94, 96, 94, 96, 94, 96, 94, 96, 94, 96, 94, 96, 94,
    96, 94, 96, 94, 96, 94, 96, 94, 96, 94, 96, 94, 96, 94,
    96, 94, 96, 94, 96, 94,
    96,  94, 96,  94, 96,  94, 96,  94, 96,  94, 96,  94, // 11
    100, 98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98,
    100, 98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98,
    100, 98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98,
    100, 98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98,
    100, 98, 100, 98, 100, 98, 100, 98, 100, 98, 100, 98,
    100,
    98, // 12
};

/// Ordinal day of year and year flags
pub const Of = struct {
    ordinal: OrdinalInt,
    year_flags: YearFlags,

    // TODO: Make this packed once packed structs aren't bugged

    pub fn clamp_ordinal(ordinal: u32) OrdinalInt {
        if (ordinal > 366) {
            return 0;
        } else {
            return @intCast(OrdinalInt, ordinal);
        }
    }

    pub fn new(ordinal: u32, year_flags: YearFlags) Of {
        return Of{
            .ordinal = clamp_ordinal(ordinal),
            .year_flags = year_flags,
        };
    }

    pub fn from_mdf(mdf: Mdf) Of {
        const mdl = mdf.to_mdl();

        // TODO: figure out if MDL_TO_OL is supposed to be checked to negative values
        if (mdl < MDL_TO_OL.len and MDL_TO_OL[mdl] > 0) {
            var ord = mdl;
            ord -%= @as(u11, @bitCast(u8, MDL_TO_OL[mdl])) & 0x3ff;
            return Of{
                .ordinal = @intCast(OrdinalInt, ord >> 1),
                .year_flags = mdf.year_flags,
            };
        } else {
            return std.mem.zeroes(Of);
        }
    }

    pub fn valid(this: @This()) bool {
        const ol = (@intCast(u10, this.ordinal) << 1) | (this.year_flags.flags >> 3);
        return MIN_OL <= ol and ol <= MAX_OL;
    }

    pub fn succ(this: @This()) @This() {
        return @This(){
            .ordinal = this.ordinal + 1,
            .year_flags = this.year_flags,
        };
    }
};

const NONLEAP_FLAGS = [7]YearFlags{ A, B, C, D, E, F, G };
const LEAP_FLAGS = [7]YearFlags{ AG, BA, CB, DC, ED, FE, GF };
const FLAGS = NONLEAP_FLAGS ++ LEAP_FLAGS;

fn of_check(expected: bool, flags: YearFlags, ordinal1: u32, ordinal2: u32) void {
    var ordinal = ordinal1;
    while (ordinal <= ordinal2) : (ordinal += 1) {
        const of = Of.new(ordinal, flags);
        expectEqual(expected, of.valid());

        if (ordinal == ordinal2) break;
    }
}

test "ordinal + year flags" {
    for (NONLEAP_FLAGS) |flags| {
        of_check(false, flags, 0, 0);
        of_check(true, flags, 1, 365);
        of_check(false, flags, 366, 1024);
        of_check(false, flags, std.math.maxInt(u32), std.math.maxInt(u32));
    }

    for (LEAP_FLAGS) |flags| {
        of_check(false, flags, 0, 0);
        of_check(true, flags, 1, 366);
        of_check(false, flags, 367, 1024);
        of_check(false, flags, std.math.maxInt(u32), std.math.maxInt(u32));
    }
}

/// Month, day of month, and year flags
pub const Mdf = struct {
    month: MonthInt,
    day: DayInt,
    year_flags: YearFlags,

    pub fn clamp_month(month: u32) MonthInt {
        if (month > 12) {
            return 0;
        } else {
            return @intCast(MonthInt, month);
        }
    }

    pub fn clamp_day(day: u32) DayInt {
        if (day > 31) {
            return 0;
        } else {
            return @intCast(DayInt, day);
        }
    }

    pub fn new(month: u32, day: u32, year_flags: YearFlags) Mdf {
        return Mdf{
            .month = clamp_month(month),
            .day = clamp_day(day),
            .year_flags = year_flags,
        };
    }

    pub fn to_mdl(this: @This()) u11 {
        return (@as(u11, this.month) << 6) |
            (@as(u11, this.day) << 1) | ((this.year_flags.flags >> 3) & 1);
    }

    pub fn valid(this: @This()) bool {
        const mdl = this.to_mdl();
        if (mdl < MDL_TO_OL.len) {
            return MDL_TO_OL[mdl] >= 0;
        } else {
            return false;
        }
    }

    pub fn to_of(this: @This()) Of {
        return Of.from_mdf(this);
    }
};

fn mdf_check(expected: bool, flags: YearFlags, month1: u32, day1: u32, month2: u32, day2: u32) void {
    var month = month1;
    while (month <= month2) : (month += 1) {
        var day = day1;
        while (day <= day2) : (day += 1) {
            const mdf = Mdf.new(month, day, flags);
            expectEqual(expected, mdf.valid());

            if (day == day2) break;
        }

        if (month == month2) break;
    }
}

test "month and day + year flags" {
    for (NONLEAP_FLAGS) |flags| {
        mdf_check(false, flags, 0, 0, 0, 1024);
        mdf_check(false, flags, 0, 0, 16, 0);
        mdf_check(true, flags, 1, 1, 1, 31);
        mdf_check(false, flags, 1, 32, 1, 1024);
        mdf_check(true, flags, 2, 1, 2, 28);
        mdf_check(false, flags, 2, 29, 2, 1024);
        mdf_check(true, flags, 3, 1, 3, 31);
        mdf_check(false, flags, 3, 32, 3, 1024);
        mdf_check(true, flags, 4, 1, 4, 30);
        mdf_check(false, flags, 4, 31, 4, 1024);
        mdf_check(true, flags, 5, 1, 5, 31);
        mdf_check(false, flags, 5, 32, 5, 1024);
        mdf_check(true, flags, 6, 1, 6, 30);
        mdf_check(false, flags, 6, 31, 6, 1024);
        mdf_check(true, flags, 7, 1, 7, 31);
        mdf_check(false, flags, 7, 32, 7, 1024);
        mdf_check(true, flags, 8, 1, 8, 31);
        mdf_check(false, flags, 8, 32, 8, 1024);
        mdf_check(true, flags, 9, 1, 9, 30);
        mdf_check(false, flags, 9, 31, 9, 1024);
        mdf_check(true, flags, 10, 1, 10, 31);
        mdf_check(false, flags, 10, 32, 10, 1024);
        mdf_check(true, flags, 11, 1, 11, 30);
        mdf_check(false, flags, 11, 31, 11, 1024);
        mdf_check(true, flags, 12, 1, 12, 31);
        mdf_check(false, flags, 12, 32, 12, 1024);
        mdf_check(false, flags, 13, 0, 16, 1024);
        mdf_check(false, flags, std.math.maxInt(u32), 0, std.math.maxInt(u32), 1024);
        mdf_check(false, flags, 0, std.math.maxInt(u32), 16, std.math.maxInt(u32));
        mdf_check(false, flags, std.math.maxInt(u32), std.math.maxInt(u32), std.math.maxInt(u32), std.math.maxInt(u32));
    }

    for (LEAP_FLAGS) |flags| {
        mdf_check(false, flags, 0, 0, 0, 1024);
        mdf_check(false, flags, 0, 0, 16, 0);
        mdf_check(true, flags, 1, 1, 1, 31);
        mdf_check(false, flags, 1, 32, 1, 1024);
        mdf_check(true, flags, 2, 1, 2, 29);
        mdf_check(false, flags, 2, 30, 2, 1024);
        mdf_check(true, flags, 3, 1, 3, 31);
        mdf_check(false, flags, 3, 32, 3, 1024);
        mdf_check(true, flags, 4, 1, 4, 30);
        mdf_check(false, flags, 4, 31, 4, 1024);
        mdf_check(true, flags, 5, 1, 5, 31);
        mdf_check(false, flags, 5, 32, 5, 1024);
        mdf_check(true, flags, 6, 1, 6, 30);
        mdf_check(false, flags, 6, 31, 6, 1024);
        mdf_check(true, flags, 7, 1, 7, 31);
        mdf_check(false, flags, 7, 32, 7, 1024);
        mdf_check(true, flags, 8, 1, 8, 31);
        mdf_check(false, flags, 8, 32, 8, 1024);
        mdf_check(true, flags, 9, 1, 9, 30);
        mdf_check(false, flags, 9, 31, 9, 1024);
        mdf_check(true, flags, 10, 1, 10, 31);
        mdf_check(false, flags, 10, 32, 10, 1024);
        mdf_check(true, flags, 11, 1, 11, 30);
        mdf_check(false, flags, 11, 31, 11, 1024);
        mdf_check(true, flags, 12, 1, 12, 31);
        mdf_check(false, flags, 12, 32, 12, 1024);
        mdf_check(false, flags, 13, 0, 16, 1024);
        mdf_check(false, flags, std.math.maxInt(u32), 0, std.math.maxInt(u32), 1024);
        mdf_check(false, flags, 0, std.math.maxInt(u32), 16, std.math.maxInt(u32));
        mdf_check(false, flags, std.math.maxInt(u32), std.math.maxInt(u32), std.math.maxInt(u32), std.math.maxInt(u32));
    }
}

test "month, day, flags to ordinal, flags" {
    for (FLAGS) |flags| {
        var month: u32 = 0;
        while (month <= 16) : (month += 1) {
            var day: u32 = 0;
            while (day <= 40) : (day += 1) {
                const mdf = Mdf.new(month, day, flags);
                const of = mdf.to_of();
                if (mdf.valid() != of.valid()) {
                    std.log.warn("mdf valid:{}\tof valid:{}", .{ mdf.valid(), of.valid() });
                    std.log.warn("{}\t{}", .{ mdf, of });
                    return error.IncorrectConversion;
                }
            }
        }
    }
}
