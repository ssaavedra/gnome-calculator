/*
 * Copyright (C) 2009 Rich Burridge
 * Copyright (C) 2012 Robert Ancell
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version. See http://www.gnu.org/copyleft/gpl.html the full text of the
 * license.
 */

private const int MAXLINE = 1024;

private static Serializer result_serializer;

static void solve (string equation)
{
    var e = new Equation (equation);
    e.base = 10;
    e.wordlen = 32;
    e.angle_units = AngleUnit.DEGREES;

    ErrorCode ret;
    var z = e.parse (out ret, null);

    if (z != null)
        stdout.printf ("%s\n", result_serializer.to_string (z));
    else if (ret == ErrorCode.MP)
        stderr.printf ("Error %s\n", mp_get_error ());
    else
        stderr.printf ("Error %d\n", ret);
}

public static int main (string[] args)
{
    /* Seed random number generator. */
    var now = new DateTime.now_utc ();
    Random.set_seed (now.get_microsecond ());

    Intl.setlocale (LocaleCategory.ALL, "");

    result_serializer = new Serializer (DisplayFormat.AUTOMATIC, 10, 9);

    var buffer = new char[1024];
    while (true)
    {
        stdout.printf ("> ");
        var line = stdin.gets (buffer);

        line = line.strip ();
        if (line == null || line == "exit" || line == "quit" || line == "")
            break;

        solve (line);
    }

    return Posix.EXIT_SUCCESS;
}