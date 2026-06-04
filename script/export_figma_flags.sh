#!/bin/bash
# Script to export SVG flag icons from Figma "All the flags" frame
# Usage: ./script/export_figma_flags.sh

set -e

FIGMA_TOKEN="${FIGMA_TOKEN:?Set FIGMA_TOKEN env variable, e.g.: FIGMA_TOKEN=figd_xxx ./script/export_figma_flags.sh}"
FILE_KEY="fybXm2qxJzwHMWgxcNMzsN"
OUTPUT_DIR="core/resources/icons/svg/flags"

# Map: "node_id|ISO_COUNTRY_CODE"
FLAGS=(
  "2135:62972|AF"
  "2135:62973|AX"
  "2135:62974|AL"
  "2135:62975|DZ"
  "2135:62976|AS"
  "2135:62977|AD"
  "2135:62978|AO"
  "2135:62979|AI"
  "2135:62980|AG"
  "2135:62981|AR"
  "2135:62982|AM"
  "2135:62983|AW"
  "2135:62984|AU"
  "2135:62985|AT"
  "2135:62986|AZ"
  "2135:62988|BS"
  "2135:62989|BH"
  "2135:62991|BD"
  "2135:62992|BB"
  "2135:62994|BY"
  "2135:62995|BE"
  "2135:62996|BZ"
  "2135:62997|BJ"
  "2135:62998|BM"
  "2135:62999|BT"
  "2135:63000|BO"
  "2135:63001|BQ"
  "2135:63002|BA"
  "2135:63003|BW"
  "2135:63004|BR"
  "2135:63006|IO"
  "2135:63007|VG"
  "2135:63008|BN"
  "2135:63009|BG"
  "2135:63010|BF"
  "2135:63011|BI"
  "2135:63012|KH"
  "2135:63013|CM"
  "2135:63014|CA"
  "2135:63016|CV"
  "2135:63017|KY"
  "2135:63018|CF"
  "2135:63020|TD"
  "2135:63021|CL"
  "2135:63022|CN"
  "2135:63023|CC"
  "2135:63024|CO"
  "2135:63025|KM"
  "2135:63026|CK"
  "2135:63028|CR"
  "2135:63029|HR"
  "2135:63031|CW"
  "2135:63032|CY"
  "2135:63033|CZ"
  "2135:63034|CD"
  "2135:63035|DK"
  "2135:63036|DJ"
  "2135:63037|DM"
  "2135:63038|DO"
  "2135:63039|TL"
  "2135:63040|EC"
  "2135:63041|EG"
  "2135:63042|SV"
  "2135:63044|GQ"
  "2135:63045|ER"
  "2135:63046|EE"
  "2135:63047|ET"
  "2135:63049|FK"
  "2135:63050|FO"
  "2135:63051|FJ"
  "2135:63052|FI"
  "2135:63053|FR"
  "2135:63054|PF"
  "2135:63055|GA"
  "2135:63057|GM"
  "2135:63058|GE"
  "2135:63059|DE"
  "2135:63060|GH"
  "2135:63061|GI"
  "2135:63062|GR"
  "2135:63063|GL"
  "2135:63064|GD"
  "2135:63065|GU"
  "2135:63066|GT"
  "2135:63067|GG"
  "2135:63068|GW"
  "2135:63069|GN"
  "2135:63070|GY"
  "2135:63071|HT"
  "2135:63073|HN"
  "2135:63074|HK"
  "2135:63075|HU"
  "2135:63076|IS"
  "2135:63077|IN"
  "2135:63078|ID"
  "2135:63080|IQ"
  "2135:63081|IE"
  "2135:63082|IM"
  "2135:63083|IL"
  "2135:63084|IT"
  "2135:63085|CI"
  "2135:63086|JM"
  "2135:63087|JP"
  "2135:63088|JE"
  "2135:63089|JO"
  "2135:63090|KZ"
  "2135:63091|KE"
  "2135:63092|KI"
  "2135:63093|XK"
  "2135:63094|KW"
  "2135:63095|KG"
  "2135:63096|LA"
  "2135:63097|LV"
  "2135:63098|LB"
  "2135:63099|LS"
  "2135:63100|LR"
  "2135:63101|LY"
  "2135:63102|LI"
  "2135:63103|LT"
  "2135:63104|LU"
  "2135:63105|MO"
  "2135:63106|MG"
  "2135:63108|MW"
  "2135:63109|MY"
  "2135:63110|MV"
  "2135:63111|ML"
  "2135:63112|MT"
  "2135:63113|MH"
  "2135:63114|MQ"
  "2135:63115|MR"
  "2135:63116|MU"
  "2135:63118|MX"
  "2135:63119|FM"
  "2135:63120|MD"
  "2135:63121|MC"
  "2135:63122|MN"
  "2135:63123|ME"
  "2135:63124|MS"
  "2135:63125|MA"
  "2135:63126|MZ"
  "2135:63127|MM"
  "2135:63128|NA"
  "2135:63130|NR"
  "2135:63131|NP"
  "2135:63132|NL"
  "2135:63133|NZ"
  "2135:63134|NI"
  "2135:63135|NE"
  "2135:63136|NG"
  "2135:63137|NU"
  "2135:63138|NF"
  "2135:63141|MP"
  "2135:63142|NO"
  "2135:63143|OM"
  "2135:63146|PK"
  "2135:63147|PW"
  "2135:63148|PS"
  "2135:63149|PA"
  "2135:63150|PG"
  "2135:63151|PY"
  "2135:63152|PE"
  "2135:63153|PH"
  "2135:63154|PN"
  "2135:63155|PL"
  "2135:63156|PT"
  "2135:63157|PR"
  "2135:63158|QA"
  "2135:63160|MK"
  "2135:63161|CG"
  "2135:63162|RO"
  "2135:63163|RU"
  "2135:63164|RW"
  "2135:63166|EH"
  "2135:63167|WS"
  "2135:63168|SM"
  "2135:63169|ST"
  "2135:63171|SA"
  "2135:63173|SN"
  "2135:63174|RS"
  "2135:63175|SC"
  "2135:63176|SL"
  "2135:63177|SG"
  "2135:63179|SX"
  "2135:63180|SK"
  "2135:63181|SI"
  "2135:63182|SB"
  "2135:63183|SO"
  "2135:63185|ZA"
  "2135:63186|KR"
  "2135:63187|SS"
  "2135:63188|ES"
  "2135:63189|LK"
  "2135:63190|BL"
  "2135:63191|LC"
  "2135:63192|VC"
  "2135:63193|SD"
  "2135:63194|SR"
  "2135:63195|SZ"
  "2135:63196|SE"
  "2135:63197|CH"
  "2135:63198|SY"
  "2135:63199|TW"
  "2135:63200|TJ"
  "2135:63201|TZ"
  "2135:63202|TH"
  "2135:63204|TG"
  "2135:63205|TK"
  "2135:63206|TO"
  "2135:63208|TT"
  "2135:63209|TN"
  "2135:63210|TR"
  "2135:63211|TM"
  "2135:63212|TC"
  "2135:63213|TV"
  "2135:63214|UG"
  "2135:63215|UA"
  "2135:63216|AE"
  "2135:63217|GB"
  "2135:63219|US"
  "2135:63220|UY"
  "2135:63221|UZ"
  "2135:63222|VU"
  "2135:63223|VA"
  "2135:63224|VE"
  "2135:63225|VN"
  "2135:63226|VI"
  "2135:63229|ZM"
  "2135:63230|ZW"
)

mkdir -p "$OUTPUT_DIR"

BATCH_SIZE=100
TOTAL=${#FLAGS[@]}
SUCCESS=0
FAIL=0

for ((batch_start=0; batch_start<TOTAL; batch_start+=BATCH_SIZE)); do
  batch_end=$((batch_start + BATCH_SIZE))
  if [ $batch_end -gt $TOTAL ]; then
    batch_end=$TOTAL
  fi

  echo "Batch $((batch_start / BATCH_SIZE + 1)): flags $((batch_start + 1))-${batch_end} of ${TOTAL}"

  # Build comma-separated node IDs for this batch
  NODE_IDS=""
  for ((i=batch_start; i<batch_end; i++)); do
    node_id="${FLAGS[$i]%%|*}"
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
    entry="${FLAGS[$i]}"
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
