#!/bin/bash

region="us-east-1"
account_id="<account_id>"
retention_days="7"
retention_date_in_seconds=$(date +%s --date "$retention_days days ago")

log() {
    echo "[$(date +"%Y-%m-%d"+"%T")]: $*"
}

cleanup_snapshots() {
echo -e "\n\n------------------cleaning up----------------------"
		snapshot_list=$(aws ec2 describe-snapshots --region $region --output=text --filter '{"Name":"description","Values":["yellowfin-mysql-sandbox*"]}'  --query Snapshots[].SnapshotId --owner-ids $account_id)
		for snapshot in $snapshot_list; do
			log "Checking $snapshot..."
			# Check age of snapshot
			snapshot_date=$(aws ec2 describe-snapshots --region $region --output=text --snapshot-ids $snapshot --query Snapshots[].StartTime --owner-ids $account_id | awk -F "T" '{printf "%s\n", $1}')
			snapshot_date_in_seconds=$(date "--date=$snapshot_date" +%s)
			snapshot_description=$(aws ec2 describe-snapshots --snapshot-id $snapshot --region $region --query Snapshots[].Description --owner-ids $account_id --output=text)

			if (( $snapshot_date_in_seconds <= $retention_date_in_seconds )); then
				log "DELETING snapshot $snapshot. Description: $snapshot_description"
				aws ec2 delete-snapshot --region $region --snapshot-id $snapshot
			else
				log "<<<< Not deleting snapshot $snapshot. Description: $snapshot_description >>>>"
			fi
		done
}	

cleanup_snapshots
