#!/bin/bash
#
# Run all the processes to build the BroTips DB4 file.
#

CSVFILE="brotips.csv"
DBFILE="brotips.db"

# kill any old copies
rm -f $CSVFILE $DBFILE "$DBFILE.xz" brotips-scrape*.html

# scrape brotips.com into a CSV file.
./brotips-scrape.php

# Check that there's a CSV file with at least 1000 lines
if [ ! -f "$CSVFILE" ]; then
	echo "Can't find the brotips file '$CSVFILE' wtf?"
	exit 1
elif [ `wc -l "$CSVFILE"` < 1000 ]; then
	echo "File abormally small."
	exit 2
fi

# Build the tips DB.
./make-tip-db.php

# Insert the key
./insert-key.php

# Test to see if the key was inserted.
./read-db.php | grep -q "\[key\]"
if [ "0" != "$?" ]; then
	echo "Crap, no key found, wtf?"
	exit 3
fi

# Compress.
xz "$DBFILE"

# Test
if [ -e "$DBFILE.xz" ]; then
	echo "All done."
	rm -f brotips*.html
else
	echo "Compression fucked up."
	exit 4
fi
