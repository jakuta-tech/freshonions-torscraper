#!/bin/sh
DIR=$( cd "$(dirname "$0")" ; pwd -P )
. $DIR/env.sh
. $ETCDIR/database
SQL="UPDATE domain SET is_fake=0, is_genuine=0 WHERE manual_genuine=0;"
LIST=`mktemp`
echo "[+] Wiping current fake / genuine"
echo $SQL | mysql -u $DB_USER  -h $DB_HOST --password=$DB_PASS $DB_BASE
echo "[+] Getting superlist"
$SCRIPTDIR/extract_from_url.sh https://www.reddit.com/r/DNMSuperlist/wiki/superlist.json > $LIST
echo "[?} VALID LIST:"
cat $LIST
echo "[+] Marking genuine ... "
$SCRIPTDIR/make_genuine.py $LIST
echo "[+] Updating fakes from clone groups ... "
$SCRIPTDIR/update_clone_fakes.sh
rm $LIST
