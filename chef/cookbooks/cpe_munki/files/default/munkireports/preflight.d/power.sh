#!/bin/sh

# Power information

# Skip manual check
if [ "$1" = 'manualcheck' ]; then
	echo 'Manual check: skipping'
	exit 0
fi

# Create cache dir if it does not exist
DIR=$(dirname $0)
mkdir -p "$DIR/cache"
powerfile="$DIR/cache/powerinfo.txt"


#### Battery Information ####

## Exit if not a MacBook, MacBook Air or MacBook Pro
AppleSmartBattery=$(ioreg -n AppleSmartBattery -r)
if [ -z "$AppleSmartBattery" ]; then
	# echo No battery information found
	echo '' > "$powerfile"
	exit 0 
fi 


## Battery ManufactureDate
ManufactureDate=$(echo "$AppleSmartBattery" | grep "ManufactureDate" | awk '{ print $NF }')
manufacture_date="manufacture_date = $ManufactureDate"

## Battery's original design capacity
DesignCapacity=$(echo "$AppleSmartBattery" | grep "DesignCapacity" | awk '{ print $NF }')
design_capacity="design_capacity = $DesignCapacity"

## Battery's current maximum capacity
MaxCapacity=$(echo "$AppleSmartBattery" | grep "MaxCapacity" | awk '{ print $NF }')
max_capacity="max_capacity = $MaxCapacity"

## Battery's current capacity
CurrentCapacity=$(echo "$AppleSmartBattery" | grep "CurrentCapacity" | awk '{ print $NF }')
current_capacity="current_capacity = $CurrentCapacity"

## Cycle count
CycleCount=$(echo "$AppleSmartBattery" | grep '"CycleCount" =' | awk '{ print $NF }')
cycle_count="cycle_count = $CycleCount"

## Battery Temperature
Temperature=$(echo "$AppleSmartBattery" | grep "Temperature" | awk '{ print $NF }')
temperature="temperature = $Temperature"

## Battery Condition
BatteryInstalled=$(echo "$AppleSmartBattery" | grep "BatteryInstalled" | awk '{ print $NF }')
if [ "$BatteryInstalled" == Yes ]; then
	Condition=`system_profiler SPPowerDataType | grep 'Condition' | awk '{$1=""; print}'`  ## print all except first column
	condition="condition = $Condition"
else
	condition="condition = No Battery"
fi


echo $manufacture_date '\n'$design_capacity '\n'$max_capacity '\n'$current_capacity '\n'$cycle_count '\n'$temperature '\n'$condition > "$powerfile"

exit 0
