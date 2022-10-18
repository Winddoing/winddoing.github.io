#!/bin/bash
##########################################################
# Copyright (C) 2022 wqshao All rights reserved.
#  File Name    : update_tags_and_categories.sh
#  Author       : wqshao
#  Created Time : 2022-10-17 17:38:57
#  Description  :
##########################################################

CUR_SHEEL_DIR=`dirname $0`

POSTS="$CUR_SHEEL_DIR/../_posts"
TAG_JSON="$CUR_SHEEL_DIR/tags.json"
CATEGORIES_JSON="$CUR_SHEEL_DIR/categories.json"

echo "POSTS: $POSTS"
echo "TAG_JSON: $TAG_JSON"
echo "CATEGORIES_JSON: $CATEGORIES_JSON"

update_tags()
{
	local cnt=1

	echo "update_tags:"

	echo > .tmp
	for post in `grep "tags:" $POSTS -rn | awk -F: '{print $1}'`
	do
		#echo "---- $post"
		grep "tags:" $post -r -A 6 | awk -F "$" '{for(i=1;i<=NF;i++){ if($i~/categories/){exit} {print $i}}}' >> .tmp
	done

	echo "{" > $TAG_JSON
	echo "  \"tags\": [" >> $TAG_JSON
	for tag in `cat .tmp | grep "^ * - " | awk '{print $2}' | sort -u`
	do
		#echo "-[$cnt] : $tag"
		echo "    \"$tag\"," >> $TAG_JSON
		cnt=$((cnt + 1))
	done
	echo "    \"默认\"" >> $TAG_JSON
	echo "  ]" >> $TAG_JSON
	echo "}" >> $TAG_JSON

	rm .tmp
	echo "update tags count: $cnt"
}

update_categories()
{
	local cnt=1

	echo "update_categories:"

	echo > .tmp
	for post in `grep "categories:" $POSTS -rn | awk -F: '{print $1}'`
	do
		#echo "---- $post"
		grep "categories:" $post -r -A 6 | awk -F "$" '{for(i=1;i<=NF;i++){ if($i~/tags/){exit} {print $i}}}' >> .tmp
	done

	echo "{" > $CATEGORIES_JSON
	echo "  \"categories\": [" >> $CATEGORIES_JSON
	for tag in `cat .tmp | grep "^ * - " | awk '{print $2}' | sort -u`
	do
		#echo "-[$cnt] : $tag"
		echo "    \"$tag\"," >> $CATEGORIES_JSON
		cnt=$((cnt + 1))
	done
	echo "    \"默认\"" >> $CATEGORIES_JSON
	echo "  ]" >> $CATEGORIES_JSON
	echo "}" >> $CATEGORIES_JSON

	rm .tmp
	echo "update categories count: $cnt"
}

#main
update_tags
update_categories
