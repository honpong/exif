#!/bin/sh
# Test output of --show-description

. ./check-vars.sh

readonly tmpfile="show-description.tmp"

# Run this in the C locale so the messages are known
LANG=C; export LANG
LANGUAGE=C; export LANGUAGE

echo Test tag 1 using text name
$EXIFEXE --ifd=Interoperability --tag=InteroperabilityIndex --show-description > "$tmpfile" 2>&1
test $? -eq 0 || { echo Incorrect return code; exit 1; }
$DIFFEXE - "$tmpfile" <<EOF
Tag 'Interoperability Index' (0x0001, 'InteroperabilityIndex'): Indicates the identification of the Interoperability rule. Use "R98" for stating ExifR98 Rules. Four bytes used including the termination code (NULL). see the separate volume of Recommended Exif Interoperability Rules (ExifR98) for other tags used for ExifR98.
EOF
test $? -eq 0 || exit 1

echo Test tag with same number but different IFD using short option names
$EXIFEXE --ifd GPS -t1 -s > "$tmpfile" 2>&1
test $? -eq 0 || { echo Incorrect return code; exit 1; }
$DIFFEXE - "$tmpfile" <<EOF
Tag 'North or South Latitude' (0x0001, 'GPSLatitudeRef'): Indicates whether the latitude is north or south latitude. The ASCII value 'N' indicates north latitude, and 'S' is south latitude.
EOF
test $? -eq 0 || exit 1

echo Test tag of 0
$EXIFEXE --ifd=GPS --tag=0 --show-description > "$tmpfile" 2>&1
test $? -eq 0 || { echo Incorrect return code; exit 1; }
$DIFFEXE - "$tmpfile" <<EOF
Tag 'GPS Tag Version' (0x0000, 'GPSVersionID'): Indicates the version of <GPSInfoIFD>. The version is given as 2.0.0.0. This tag is mandatory when <GPSInfo> tag is present. (Note: The <GPSVersionID> tag is given in bytes, unlike the <ExifVersion> tag. When the version is 2.0.0.0, the tag value is 02000000.H).
EOF
test $? -eq 0 || exit 1

echo Test --machine-readable using hexadecimal tag
$EXIFEXE --ifd=1 --tag=0x103 --show-description --machine-readable > "$tmpfile" 2>&1
test $? -eq 0 || { echo Incorrect return code; exit 1; }
$DIFFEXE - "$tmpfile" <<EOF
0x0103	Compression	Compression	The compression scheme used for the image data. When a primary image is JPEG compressed, this designation is not necessary and is omitted. When thumbnails use JPEG compression, this tag value is set to 6.
EOF
test $? -eq 0 || exit 1

echo Test tag with number not in IFD
$EXIFEXE --ifd=EXIF --tag=1 --show-description > "$tmpfile" 2>&1
test $? -eq 1 || { echo Incorrect return code; exit 1; }
$DIFFEXE - "$tmpfile" <<EOF
Unknown Tag
EOF
test $? -eq 0 || exit 1

echo "Test tag with number > 65535"
$EXIFEXE --ifd=GPS --tag=65537 --show-description > "$tmpfile" 2>&1
test $? -eq 1 || { echo Incorrect return code; exit 1; }
$DIFFEXE - "$tmpfile" <<EOF
Unknown Tag
EOF
test $? -eq 0 || exit 1

echo Test invalid tag name
$EXIFEXE --ifd=0 --tag=Xyzzy --show-description > "$tmpfile" 2>&1
test $? -eq 1 || { echo Incorrect return code; exit 1; }
$DIFFEXE - "$tmpfile" <<EOF
Invalid tag 'Xyzzy'!
EOF
test $? -eq 0 || exit 1

echo Test tag with invalid IFD
$EXIFEXE --ifd=XYZZY --tag=0x100 --show-description > "$tmpfile" 2>&1
test $? -eq 1 || { echo Incorrect return code; exit 1; }
$DIFFEXE - "$tmpfile" <<EOF
Invalid IFD 'XYZZY'. Valid IFDs are '0', '1', 'EXIF', 'GPS', and 'Interoperability'.
EOF
test $? -eq 0 || exit 1

echo Test missing tag name
$EXIFEXE --ifd=0 --show-description > "$tmpfile" 2>&1
test $? -eq 1 || { echo Incorrect return code; exit 1; }
$DIFFEXE - "$tmpfile" <<EOF
You need to specify a tag!
EOF
test $? -eq 0 || exit 1

echo Test missing IFD
$EXIFEXE --tag=1 --show-description > "$tmpfile" 2>&1
test $? -eq 1 || { echo Incorrect return code; exit 1; }
$DIFFEXE - "$tmpfile" <<EOF
You need to specify an IFD!
EOF
test $? -eq 0 || exit 1

# Cleanup
echo PASSED
rm -f "$tmpfile"
