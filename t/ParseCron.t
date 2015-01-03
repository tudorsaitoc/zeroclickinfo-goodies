#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use DDG::Test::Goodie;

zci answer_type => 'parsecron';
zci is_cached => 0;

ddg_goodie_test(
	[qw(
		DDG::Goodie::ParseCron
	)],
    # Time
    'cron * * * * *' => test_zci('every minute'),
    'cron 5 0 * * *' => test_zci('at 12:05am every day'),
    'cron 0 */2 * * *' => test_zci('every other hour'),
    'cron 0 0-23/2 * * *' => test_zci('every other hour from 12am to 11pm'),
    'cron 15 0-23/2,10,14 * * *' => test_zci('15 minutes after every other hour from 12am to 11pm, 10am, and 2pm every day'),
    'cron 0,15,30,45 4 * * *' => test_zci('at 4:00am, 4:15am, 4:30am, and 4:45am every day'), # exact times are returned
    'cron 45,15,30,15,0 4 * * *' => test_zci('at 4:00am, 4:15am, 4:30am, and 4:45am every day'),
    'cron 0,15,30,45 4,6,7,8 * * *' => test_zci('0, 15, 30, and 45 minutes after 4am, 6am, 7am, and 8am every day'), # too many exact times
    'cron 45,15,30,15,0 4,6,7,8 * * *' => test_zci('45, 15, 30, 15, and 0 minutes after 4am, 6am, 7am, and 8am every day'),
    'cron 5 1,4,6-7 * * *' => test_zci('at 1:05am, 4:05am, 6:05am, and 7:05am every day'),
    'cron 5 13,5 * * *' => test_zci('at 5:05am and 1:05pm every day'),
    'cron 1-9/2 * * * *' => test_zci('every other minute from 1 to 9 minutes after every hour'),
    'cron */5 4 * * *' => test_zci('every 5 minutes of 4am'),
    'cron */5 * * * *' => test_zci('every 5 minutes'),
    'crontab * */3 * * *' => test_zci('every minute of every 3 hours'),
    
    # Dates
    'cron 0 9 */3 * *' => test_zci('at 9:00am every 3 days'),
    'cron 0 9 */1 * *' => test_zci('at 9:00am every day'),
    'cron 0 9 1-15/2 * *' => test_zci('at 9:00am every other day from 1st to 15th of every month'),
    'cron 0 9 * 6-8 *' => test_zci('at 9:00am every day of June through August'),
    'cron 0 9 */5 6-8 *' => test_zci('at 9:00am every 5 days of June through August'),
    'cron 0 12 * */2 *' => test_zci('at 12:00pm every day of every other month'),
    'cron 0 12 * * */2' => test_zci('at 12:00pm every other day of the week'),
    'cron 0 0 23 * *' => test_zci('at midnight on the 23rd of every month'), # test ordinal suffixes
    'cron 0 0 13 * *' => test_zci('at midnight on the 13th of every month'),
    'cron 0 0 22 * *' => test_zci('at midnight on the 22nd of every month'),
    'cron 0 0 21 * *' => test_zci('at midnight on the 21st of every month'),
    'cron 0 0 20 * *' => test_zci('at midnight on the 20th of every month'),
    'cron 0 0 1,14 1-11 *' => test_zci('at midnight on the 1st and 14th of January through November'),
    'cron 0 0 * * 1-5' => test_zci('at midnight Monday through Friday'),
    'cron 0 0 * 12 1-5' => test_zci('at midnight Monday through Friday in December'),
    'cron 0 0 23 * 1-5' => test_zci('at midnight on the 23rd and Monday through Friday'),
    'cron 0 0 23 1 1-5' => test_zci('at midnight on the 23rd and Monday through Friday in January'),
    'cron 0 0 * * 1-5' => test_zci('at midnight Monday through Friday'),
    'cron 0 0 * * Sat-Sun' => test_zci('at midnight Saturday through Sunday'),
    'cron 0 0 * DEC,Jan-feb Sat-Sun' => test_zci('at midnight Saturday through Sunday in December and January through February'),
    'cron 0 0 * * 0' => test_zci('at midnight on Sunday'),
    'cron 0 0 * * 7' => test_zci('at midnight on Sunday'),
    
    # Syntax errors
    'cron 0 0 * *' => undef,
    'cron 0 0 *' => undef,
    'cron 0 0' => undef,
    'cron 0' => undef,
    'cron ' => undef,
    'cron help' => undef,
    'cron cheatsheet' => undef,
    'crontab examples' => undef,
    
    'cron 96 4 * * *' => test_zci('Invalid minute 96'),
    'cron 6 45 * * *' => test_zci('Invalid hour 45'),
    'cron 15,1-93 5 * * *' => test_zci('Invalid minute 93'),
    'cron 15,93-7 5 * * *' => test_zci('Invalid minute 93'),
    'cron 1 50,16 * * *' => test_zci('Invalid hour 50'),
    'cron 0 0 32 * *' => test_zci('Invalid day 32'),
    'cron 0 0 0 * *' => test_zci('Invalid day 0'),
    'cron 0 0 2 0 *' => test_zci('Invalid month 0'),
    'cron 0 0 * * 8' => test_zci('Invalid day of the week 8'),
    'cron 0 0 * * -1' => test_zci('Invalid day of the week -1'),
    'cron 0 0 * ABC *' => test_zci('Invalid month ABC'),
    'cron 0 0 ABC * *' => test_zci('Invalid day ABC'),
    'cron ! * * * *' => test_zci('Invalid minute !'),
    'cron 0 9 */90 * *' => test_zci('Invalid day 90'),
    'cron 0 9 */0 * *' => test_zci('Invalid day 0'),
    
    # Complex examples
    'crontab 42 12 3 Feb Sat' => test_zci('at 12:42pm on the 3rd and on Saturday in February'),
);

done_testing;
