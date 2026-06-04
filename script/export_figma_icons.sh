#!/bin/bash
# Script to export SVG icons from Figma ICONS frame
# Usage: ./script/export_figma_icons.sh

set -e

FIGMA_TOKEN="${FIGMA_TOKEN:?Set FIGMA_TOKEN env variable, e.g.: FIGMA_TOKEN=figd_xxx ./script/export_figma_icons.sh}"
FILE_KEY="fybXm2qxJzwHMWgxcNMzsN"
OUTPUT_DIR="core/resources/icons/svg/new"

# Map: "node_id|filename"
ICONS=(
  "3552:13935|notification_default"
  "3552:13933|sort"
  "3552:13916|forward_share"
  "3552:13923|notification_active"
  "3552:13926|message"
  "3552:13924|home"
  "3552:13928|home_fill"
  "3552:13917|user"
  "3552:13921|user_fill"
  "3552:13934|message_fill"
  "3552:13918|music"
  "3552:13915|music_fill"
  "3552:13914|music_text"
  "3552:13912|jggl_default"
  "3552:13929|jggl_active"
  "3552:13927|music_repeat"
  "3552:13911|download"
  "3552:13925|dots_menu"
  "3552:13909|arrow"
  "3552:13932|search"
  "3552:13922|music_top"
  "3552:13930|music_down"
  "3552:13913|music_up"
  "3552:13910|posts"
  "3654:19343|posts_fill"
  "3552:13907|approve"
  "3552:13906|bookmark"
  "3552:13905|check_circle_fill"
  "3843:21886|check_circle_not_filled"
  "3913:24424|count_10_max"
  "3966:26044|filled_count_10_max"
  "3973:26200|empty"
  "3977:26466|pin"
  "3977:26543|mute"
  "3552:13904|add"
  "3552:13903|link"
  "3552:13902|share"
  "3552:13901|add_dots"
  "3552:13899|close"
  "3552:13920|check"
  "3552:13898|visible"
  "3552:13896|hidden"
  "3552:13895|warning"
  "3552:13893|history"
  "3552:13892|edit"
  "3552:13900|chat_read"
  "3552:13919|attach"
  "3552:13931|background"
  "3552:13891|decline"
  "3552:13894|delete"
  "3552:13897|music_back"
  "3552:13908|music_forward"
  "3563:15111|text_message"
  "3567:15528|apple"
  "3567:15527|google"
  "3591:20567|send"
  "3578:23471|camera_rotate"
  "3597:3234|sticker"
  "3597:31048|photo"
  "3597:31058|image"
  "3597:35553|delete_circle"
  "3617:26954|flash_on"
  "3787:20991|list"
  "3807:20923|pause"
  "3807:20983|play"
  "3833:22514|bookmark_fill"
  "3843:21627|video"
  "3843:21645|microphone"
  "3904:27003|author"
  "3925:24123|loading"
  # --- New icons from Figma ICONS frame ---
  "4585:443785|chart"
  "4708:91645|keyboard"
  "4284:27648|forward"
  "6330:162005|message_unread"
  "4284:28030|check_circle"
  "4284:39513|copy"
  "4284:39798|arrow_forward"
  "4539:405510|arrow_right"
  "5313:94462|quit"
  "5313:90704|lock"
  "5313:94021|unlock"
  "4313:44101|plus"
  "4809:159273|variant85"
  "4948:29866|downloading"
  "4863:139874|big_circle_count"
  "4313:44155|unmute"
  "4284:27898|info"
  "5883:116311|support"
  "5883:123170|language"
  "5883:123195|variant101"
  "5883:124928|moment"
  "5674:70108|variant95"
  "5883:73810|generations"
  "4463:30809|flash_off"
  "4463:46340|dot"
  "4471:52579|group_of_people"
  "4684:73511|notification_off"
  "5279:38197|images"
  "5564:79577|profile_added"
  "5564:113084|profile_add"
  "5601:25922|promotion"
  "5883:112653|customize"
  "5883:112687|settings"
  "6330:162030|message_fill_unread"
  "6585:338644|phone"
  "6637:119222|card"
  "6637:119306|paypal"
  "6585:354216|laptop"
  "7085:119456|email"
  "7085:75285|phone_2"
  "7085:119470|arrow_left"
  "7085:119475|arrow_down"
  "7085:119485|arrow_up"
  "7142:118978|avatar"
  "7198:130879|privacy"
  "7198:131134|security"
  "7250:98843|menu"
  "8187:30169|info_fill"
  "8530:184796|password"
  "9378:290280|10_sec_back"
  "9385:312902|10_sec_forward"
)

mkdir -p "$OUTPUT_DIR"

BATCH_SIZE=50
TOTAL=${#ICONS[@]}
SUCCESS=0
FAIL=0

for ((batch_start=0; batch_start<TOTAL; batch_start+=BATCH_SIZE)); do
  batch_end=$((batch_start + BATCH_SIZE))
  if [ $batch_end -gt $TOTAL ]; then
    batch_end=$TOTAL
  fi

  echo "Batch $((batch_start / BATCH_SIZE + 1)): icons $((batch_start + 1))-${batch_end} of ${TOTAL}"

  # Build comma-separated node IDs for this batch
  NODE_IDS=""
  for ((i=batch_start; i<batch_end; i++)); do
    node_id="${ICONS[$i]%%|*}"
    if [ -n "$NODE_IDS" ]; then
      NODE_IDS="${NODE_IDS},${node_id}"
    else
      NODE_IDS="${node_id}"
    fi
  done

  echo "  Requesting SVG URLs from Figma API..."

  RESPONSE=$(curl -s -H "X-Figma-Token: $FIGMA_TOKEN" \
    "https://api.figma.com/v1/images/$FILE_KEY?ids=${NODE_IDS}&format=svg")

  HAS_ERROR=$(echo "$RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
err = data.get('err')
if err is not None:
    print(err)
" 2>&1)

  if [ -n "$HAS_ERROR" ]; then
    echo "  Error from Figma API: $HAS_ERROR"
    echo "  Response: $RESPONSE"
    exit 1
  fi

  echo "  Downloading SVGs..."

  for ((i=batch_start; i<batch_end; i++)); do
    entry="${ICONS[$i]}"
    node_id="${entry%%|*}"
    filename="${entry##*|}"

    svg_url=$(echo "$RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
images = data.get('images', {})
url = images.get('$node_id', '')
print(url)
")

    if [ -z "$svg_url" ] || [ "$svg_url" = "null" ] || [ "$svg_url" = "None" ]; then
      echo "    SKIP: $filename (no URL returned)"
      FAIL=$((FAIL + 1))
      continue
    fi

    HTTP_CODE=$(curl -s -o "$OUTPUT_DIR/${filename}.svg" -w "%{http_code}" "$svg_url")

    if [ "$HTTP_CODE" = "200" ]; then
      echo "    OK: ${filename}.svg"
      SUCCESS=$((SUCCESS + 1))
    else
      echo "    FAIL: ${filename}.svg (HTTP $HTTP_CODE)"
      rm -f "$OUTPUT_DIR/${filename}.svg"
      FAIL=$((FAIL + 1))
    fi
  done
done

echo ""
echo "Done! Downloaded: $SUCCESS, Failed: $FAIL"
echo "Output: $OUTPUT_DIR/"
