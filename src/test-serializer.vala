/*
 * Copyright (C) 2012 Arth Patel
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

private int fail_count = 0;
private int pass_count = 0;
private const string thousand_separator = ",";
private const string radix_string = ".";

private void pass (string? text = null)
{
    //stdout.printf ("PASS: %s\n", text);
    pass_count++;
}

private void fail (string text)
{
    stdout.printf ("*FAIL: %s\n", text);
    fail_count++;
}

private void test_number (Serializer s, string number, int base_value, string expected_string)
{
    var n = mp_set_from_string (number, base_value);
    s.set_base (base_value);
    if (s.to_string (n) == expected_string)
        pass ();
    else
        fail ("Serializer returned (%s) => expected value (%s)".printf (s.to_string (n), expected_string));
}

private void test_fixed (Serializer s)
{
    s.set_number_format (DisplayFormat.FIXED);

    test_number (s, "123456789012345678901234", 10, "123,456,789,012,345,678,901,234");
    test_number (s, "0.1234567890123456789012", 10, "0.123456789");
    test_number (s, "101010101010101010101010", 2, "101010101010101010101010");
    test_number (s, "0.1010101010101010101010", 2, "0.101010101");
    test_number (s, "123456701234567012345670", 8, "123456701234567012345670");
    test_number (s, "0.1234567012345670123456", 8, "0.123456701");
    test_number (s, "123456789ABCDEF012345678", 16, "123456789ABCDEF012345678");
    test_number (s, "0.ABCDEF0123456789ABCDEF", 16, "0.ABCDEF012");
}

private void test_automatic (Serializer s)
{
    s.set_number_format (DisplayFormat.AUTOMATIC);

    test_number (s, "0.10", 10, "0.1");
    test_number (s, "0.12345678901234567890", 10, "0.123456789");
    test_number (s, "123456789012", 10, "123,456,789,012");
    test_number (s, "12345678901234567890", 10, "1.23456789×10¹⁹");

    test_number (s, ".10", 2, "0.1");
    test_number (s, "0.10101010101010101010", 2, "0.101010101");
    test_number (s, "1010101010101010101010101010101010101010101010101010101010101010", 2, "1010101010101010101010101010101010101010101010101010101010101010");
    test_number (s, "10101010101010101010101010101010101010101010101010101010101010101", 2, "1.010101011×10⁶⁴");

    test_number (s, "0.10", 8, "0.1");
    test_number (s, "0.12345670123456701234", 8, "0.123456701");
    test_number (s, "1234567012345670123456", 8, "1234567012345670123456");
    test_number (s, "12345670123456701234567", 8, "1.234567012×10²²");

    test_number (s, "0.10", 16, "0.1");
    test_number (s, "0.123456789ABCDEF01234", 16, "0.12345678A");
    test_number (s, "123456789ABCDEF0", 16, "123456789ABCDEF0");
    test_number (s, "123456789ABCEDF01", 16, "1.23456789B×10¹⁶");
}

private void test_scientific (Serializer s)
{
    s.set_number_format (DisplayFormat.SCIENTIFIC);

    test_number (s, "1", 10, "1");
    test_number (s, "10", 10, "1×10¹");
    test_number (s, "1234567890", 10, "1.23456789×10⁹");
    test_number (s, "0.1", 10, "1×10⁻¹");
    test_number (s, "0.1234567890", 10, "1.23456789×10⁻¹");
}

private void test_engineering (Serializer s)
{
    s.set_number_format (DisplayFormat.ENGINEERING);

    test_number (s, "1", 10, "1");
    test_number (s, "10", 10, "10");
    test_number (s, "1234567890", 10, "1.23456789×10⁹");
    test_number (s, "0.1", 10, "100×10⁻³");
    test_number (s, "0.1234567890", 10, "123.456789×10⁻³");
}

static int main (string[] args)
{
    Intl.setlocale (LocaleCategory.ALL, "C");
    var serializer = new Serializer (DisplayFormat.AUTOMATIC, 10, 9);
    serializer.set_thousands_separator (thousand_separator.get_char ());
    serializer.set_radix (radix_string.get_char ());
    serializer.set_show_thousands_separators (true);
    serializer.set_thousands_separator_count (3);

    test_fixed (serializer);
    test_automatic (serializer);
    test_scientific (serializer);
    test_engineering (serializer);

    if (fail_count == 0)
        stdout.printf ("Passed all %i tests\n", pass_count);
    else
        stdout.printf ("Failed %i/%d tests\n", fail_count, pass_count + fail_count);

    return fail_count;
}