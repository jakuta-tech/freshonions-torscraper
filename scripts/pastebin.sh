#!/bin/sh
DIR=$( cd "$(dirname "$0")" ; pwd -P )
. $DIR/env.sh
RECENT_PASTES=`mktemp`
ONION_URLS=`mktemp`
PURIFIED=`mktemp`
https_proxy='' curl https://pastebin.com/api_scraping.php | grep -E -o 'https://pastebin\.com/api_scrape_item\.php\?i=[a-zA-Z0-9]+' > $RECENT_PASTES
echo "Recent pastes ($RECENT_PASTES):"
cat $RECENT_PASTES
cat $RECENT_PASTES | xargs -n 1 -P 10 -I {} /bin/sh -c "$SCRIPTDIR/extract_from_url.sh {} >> $ONION_URLS"
$SCRIPTDIR/purify.sh $ONION_URLS > $PURIFIED
echo "Raw onions:"
cat $ONION_URLS
FOUND=`wc -l $PURIFIED | cut -f 1 -d ' '`
echo "Found '$FOUND' onions:"
cat $PURIFIED


if [ $FOUND -gt 0 ]; then
	(
	cd $BASEDIR
	scrapy crawl tor -a load_links=$PURIFIED -a test=yes
)
fi;
rm $RECENT_PASTES
rm $ONION_URLS
rm $PURIFIED
