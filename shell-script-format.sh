#!/bin/bash

set -euo pipefail

# 📥 Input from Harness
payload='<+pipeline.variables.unattached_disks>'  # Replace with actual string when testing locally

echo "Raw payload:"
echo "$payload"

# Extract each disk entry (split into lines)
disks=$(echo "$payload" | tr '{' '\n' | grep '"name"')

echo "Parsed disk entries:"
echo "$disks"

# Start HTML table
html_content="<html><body><h2>GCP Unattached Disks</h2><table border='1' cellpadding='5'><tr><th>Project ID</th><th>Zone</th><th>Disk Name</th></tr>"

# Loop through each line
while read -r disk; do
  disk_name=$(echo "$disk" | sed -n 's/.*"name":"\([^"]*\)".*/\1/p')
  link=$(echo "$disk" | sed -n 's/.*"link":"\([^"]*\)".*/\1/p')
  project_id=$(echo "$link" | sed -n 's#.*/projects/\([^/]*\)/.*#\1#p')
  zone=$(echo "$link" | sed -n 's#.*/zones/\([^/]*\)/.*#\1#p')

  if [[ -n "$disk_name" && -n "$project_id" && -n "$zone" ]]; then
    html_content+="<tr><td>$project_id</td><td>$zone</td><td>$disk_name</td></tr>"
  fi
done <<< "$disks"

html_content+="</table></body></html>"

# Output the HTML content for verification
echo "$html_content"
