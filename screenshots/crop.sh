#!/usr/bin/env bash

mkdir -p cropped_output
TEMP_DATA=$(mktemp)

echo "--- PASS 1: Analyzing dimensions ---"
max_width=0

for img in preview*.{png,jpg,jpeg}; do
	[[ -e "$img" ]] || continue

	width=$(magick identify -format "%w" "$img")
	height=$(magick identify -format "%h" "$img")
	corner_color=$(magick identify -format "%[hex:p{0,0}]" "$img")

	# Detect left crop boundary
	crop_x=0
	for ((x = 0; x < width; x += 1)); do
		color_hex=$(magick identify -format "%[hex:p{$x,$((height / 2))}]" "$img")
		if [[ "$color_hex" != "$corner_color" ]]; then
			crop_x=$x
			break
		fi
	done

	if [[ "$crop_x" -gt 100 ]]; then crop_x=0; fi

	adjusted_width=$((width - crop_x))

	# Save ALL necessary variables explicitly to avoid leakage
	echo "$img:$width:$crop_x:$height:$corner_color" >>"$TEMP_DATA"

	if ((adjusted_width > max_width)); then
		max_width=$adjusted_width
	fi
done

echo "-> Target uniform width set to maximum: ${max_width}px"
echo ""
echo "--- PASS 2: Processing with locked dimensions ---"

while IFS=: read -r img orig_width crop_x height corner_color; do
	[[ -e "$img" ]] || continue

	# Sanitize hex color to 6 digits safely
	safe_color="#${corner_color:0:6}"

	# Calculate exact crop width for this specific image
	crop_w=$((orig_width - crop_x))

	echo "Processing $img (Crop W: $crop_w, H: $height -> Extended to ${max_width}x$height)..."

	# 1. Crop using the image's OWN original width and height (prevents any squishing)
	# 2. Extends/pads the right side to max_width using the exact background color
	magick "$img" \
		-crop "${crop_w}x${height}+${crop_x}+0" \
		+repage \
		-background "$safe_color" \
		-gravity West \
		-extent "${max_width}x${height}" \
		"cropped_output/$img"

done <"$TEMP_DATA"

rm -f "$TEMP_DATA"
echo "Done! All images are crisp, un-squished, and uniformly aligned."
