REV_HASH="8569bc5e0d1bdc4b252bf3f4e7c893ea2e17c98f"
git checkout ${REV_HASH}
REV_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
 
# Replace all src-git with src-git-full: https://openwrt.org/docs/guide-developer/feeds#feed_configuration
sed -e "/^src-git\S*/s//src-git-full/" feeds.conf.default > feeds.conf
 
./scripts/feeds update -a
 
# Edit every line of feeds.conf in a loop to set the chosen revision hash
sed -n -e "/^src-git\S*\s/{s///;s/\s.*$//p}" feeds.conf \
| while read -r FEED_ID
do
REV_DATE="$(git log -1 --format=%cd --date=iso8601-strict)"
REV_HASH="$(git -C feeds/${FEED_ID} rev-list -n 1 --before=${REV_DATE} ${REV_BRANCH})"
sed -i -e "/\s${FEED_ID}\s.*\.git$/s/$/^${REV_HASH}/" feeds.conf
done
 
./scripts/feeds update -a
./scripts/feeds install -a