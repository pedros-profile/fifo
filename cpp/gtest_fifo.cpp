#include <gtest/gtest.h>
#include <random>

#include "fifo.cpp"

// Test fixture
class TestFifoCpp : public ::testing::Test {
protected:
    Fifo dut;
};

/* --------------------------------------------------------------- *
 * Write and read back one value a time. Assert read values match. *
 * --------------------------------------------------------------- */
TEST_F(TestFifoCpp, ReadBackSingleValues) {
    long dut_val;

    std::mt19937 rng(0xC0FFEE);
    std::uniform_int_distribution<long> dist;

    for (int i = 0; i < DEPTH + 2; ++i) {
        long val = dist(rng);
        dut.write(val);
        dut.read(&dut_val);
        EXPECT_EQ(dut_val, val);
    }
}

/* ------------------------------------------------ *
 * Write a bulk of values, then read them all back. *
 * Assert read values match.                        *
 * ------------------------------------------------ */
TEST_F(TestFifoCpp, ReadBackBulkValues) {
    long dut_val;

    for (int i = 0; i < DEPTH - 1; ++i) {
        auto stat = dut.write(i);
        EXPECT_EQ(stat, PARTIAL)
            << "Failed to write value " << i;
    }

    for (int i = 0; i < DEPTH - 1; ++i) {
        dut.read(&dut_val);
        EXPECT_EQ(dut_val, i)
            << "Read value mismatch at entry #" << i;
    }
}

/* -------------------------------------------- *
 * Test if FIFO overflow is returned from write *
 * -------------------------------------------- */
TEST_F(TestFifoCpp, Overflow) {
    // Almost fill FIFO
    for (int i = 0; i < DEPTH - 1; ++i) {
        auto stat = dut.write(i);
        EXPECT_EQ(stat, PARTIAL);
    }

    // Make it full
    auto stat = dut.write(100);
    EXPECT_EQ(stat, FULL);
    EXPECT_EQ(dut.status, FULL);

    // Overflow
    stat = dut.write(101);
    EXPECT_EQ(stat, OVERFLOW);
    EXPECT_EQ(dut.status, FULL);
}

/* -------------------------------------------- *
 * Test if FIFO underflow is returned from read *
 * -------------------------------------------- */
TEST_F(TestFifoCpp, Underflow) {
    long dut_val = -117;

    // Startup underflow
    auto stat = dut.read(&dut_val);
    EXPECT_EQ(stat, UNDERFLOW);
    EXPECT_EQ(dut_val, -117);   // value must remain unchanged

    // Write some values (not full)
    std::mt19937 rng(42);
    int count = (rng() % (DEPTH - 1)) + 1;

    for (int i = 0; i < count; ++i) {
        stat = dut.write(i);
        EXPECT_EQ(stat, PARTIAL);
    }

    // Read them all back
    for (int i = 0; i < count; ++i) {
        stat = dut.read(&dut_val);
        EXPECT_NE(stat, UNDERFLOW);
    }

    // Runtime underflow
    long prev_val = dut_val;
    stat = dut.read(&dut_val);
    EXPECT_EQ(stat, UNDERFLOW);
    EXPECT_EQ(dut_val, prev_val);
}

/* --------------------------------------------------------- *
 * Test a full cycle of filling up and emptying a FIFO twice *
 * --------------------------------------------------------- */
TEST_F(TestFifoCpp, UnderAndOverflowCycle) {
    long dut_val;

    std::mt19937 rng(123);
    std::uniform_int_distribution<long> dist;

    for (int cycle = 0; cycle < 2; ++cycle) {
        long values[DEPTH + 3];

        for (int i = 0; i < DEPTH + 3; ++i)
            values[i] = dist(rng);

        values[DEPTH] = 123;  // deterministic non-sentinel

        EXPECT_EQ(dut.status, EMPTY);

        // Write up to one less than full
        for (int i = 0; i < DEPTH - 1; ++i) {
            auto stat = dut.write(values[i]);
            EXPECT_EQ(stat, PARTIAL);
            EXPECT_EQ(dut.status, PARTIAL);
        }

        // Fill FIFO
        auto stat = dut.write(values[DEPTH - 1]);
        EXPECT_EQ(stat, FULL);
        EXPECT_EQ(dut.status, FULL);

        // Read all but last
        for (int i = 0; i < DEPTH - 1; ++i) {
            stat = dut.read(&dut_val);
            EXPECT_EQ(stat, PARTIAL);
            EXPECT_EQ(dut.status, PARTIAL);
            EXPECT_EQ(dut_val, values[i]);
        }

        // Read last value
        stat = dut.read(&dut_val);
        EXPECT_EQ(stat, EMPTY);
        EXPECT_EQ(dut.status, EMPTY);
        EXPECT_EQ(dut_val, values[DEPTH - 1]);

        // Underflow
        long prev_val = dut_val;
        stat = dut.read(&dut_val);
        EXPECT_EQ(stat, UNDERFLOW);
        EXPECT_EQ(dut.status, EMPTY);
        EXPECT_EQ(dut_val, prev_val);
    }
}

/* ------------------------------------------------------------ *
 * Verify that bound values are written and read back untouched *
 * ------------------------------------------------------------ */
TEST_F(TestFifoCpp, ValueBounds) {
    long dut_val;

    // Lower bound
    auto stat = dut.write(LONG_MIN);
    EXPECT_EQ(stat, PARTIAL);
    dut.read(&dut_val);
    EXPECT_EQ(dut_val, LONG_MIN);

    // Upper bound
    stat = dut.write(LONG_MAX);
    EXPECT_EQ(stat, PARTIAL);
    dut.read(&dut_val);
    EXPECT_EQ(dut_val, LONG_MAX);
}
