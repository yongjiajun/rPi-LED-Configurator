#!/bin/bash

# prevent the use of CTRL-C exit
trap '' 2 

# path variables
readonly pwd=`pwd`
readonly led_path='/sys/class/leds' 
readonly bash_path='/bin/bash'
readonly bgscript_path="$pwd/bgtask.sh"
readonly dev_null_path="/dev/null"

# displays main menu
function mainMenu(){
	
	cd $led_path || exit

	# get items in led path
	local ITEMS=($(ls -d *))
	local totalItems=${#ITEMS[@]}
	local index=1
	local led

	printf "\nWelcome to %s Led_Konfigurator!" "s3688090's"
	printf "\n============================"
	printf "\nPlease select an led to configure:\n"

	for (( i=0; i<$totalItems; i++ ))
	do
		printf "\n%d. %s" "$index" "${ITEMS[i]}"
		((index++))
	done

	printf "\n%d. Quit\n" "$((($totalItems)+1))"

	printf "\nPlease enter a number (1-%d) for the led to configure or quit:\n" "$((($totalItems)+1))"

	read led

	if [[ ! $led -gt $totalItems ]] && [[ $led -gt 0 ]]
	then
		# change directory to LED's folder
		((led--))
		cd ${ITEMS[led]} || exit
		selectLed
	elif [[ $led = $(($totalItems+1)) ]]
	then
		printf "\nBye!\n"
	else
		printf "\nPlease enter a correct input!\n"
		mainMenu
	fi
}

function selectLed(){

	local led_name
	local selectOption
	local processes
	local numProcesses

	# get led name by printing current directory's name
	led_name="$(basename "$PWD")"

	printf "\n%s" "$led_name"
	printf "\n=========="
	printf "\nWhat would you like to do with this led?"
	printf "\n1) turn on"
	printf "\n2) turn off"
	printf "\n3) associate with a system event"
	printf "\n4) associate with the performance of a process"
	printf "\n5) stop association with a process' performance"
	printf "\n6) quit to main menu"
	printf "\n\nPlease enter a number (1-6) for your choice:\n"

	read selectOption

	if [[ "$selectOption" = "1" ]]
	then
		# turn on selected LED
		echo 1 > brightness
		printf "\n%s has been turned on.\n" "$led_name"
	elif [[ "$selectOption" = "2" ]]
	then
		# turn off selected LED
		echo 0 > brightness
		printf "\n%s has been turned off.\n" "$led_name"
	elif [[ "$selectOption" = "3" ]]
	then
		# to associate LED with a system event
		sysEvent
		return 0
	elif [[ "$selectOption" = "4" ]] 
	then
		# to associate LED with the performance of a process
		# check if script is already running
		processes=($(pgrep -f bgtask.sh))
		numProcesses=${#processes[@]}

		# if script isn't running, associate LED with the performance of a process
		if [[ numProcesses -eq 0 ]]
		then
			associate_led_perf
			return 0
		else 
			printf "\n%s is currently associated with the performance of a process! Please use option 5 to kill it!\n" "$led_name"
			selectLed
			return 0
		fi
	elif [[ "$selectOption" = "5" ]] 
	then
		# to disassociate LED with the performance of a process

		# check if script is already running
		processes=($(pgrep -f bgtask.sh)) #pgrep -f ? + ps -p ? -o comm=
		numProcesses=${#processes[@]}

		# if script is running, disassociate LED with the performance of a process
		if [[ numProcesses -eq 0 ]]
		then
			printf "\n%s has not been associated with the performance of a process!\n" "$led_name"
			selectLed
			return 0
		else 
			# kills the background running script
			kill -PIPE ${processes[0]} > $dev_null_path

			# turns off LED
			echo 0 > brightness

			printf "\n%s has been disassociated with the performance of a process.\n" "$led_name"
			mainMenu
			return 0
		fi
	elif [[ "$selectOption" = "6" ]] 
	then
		# go back to main menu
		mainMenu
		return 0	
	else
		printf "\nPlease enter a correct input!\n"
		selectLed
		return 0
	fi
			
	mainMenu
}

function sysEvent(){
	
	# get available system events
	local EVENTS=($(cat trigger))
	local totalEvents=${#EVENTS[@]}

	local eventInput
	local indexEvents=1

	printf "\nAssociate Led with a system Event"
	printf "\n================================="
	printf "\nAvailable events are: "
	printf "\n---------------------"

	for (( i=0; i<$totalEvents; i++ ))
	do
		# filter currently selected event
		if grep -q "\[" <<<"${EVENTS[i]}";
		then
			EVENTS[i]=${EVENTS[i]//'['}
			EVENTS[i]=${EVENTS[i]//']'}
			printf "\n%d) %s*" "$indexEvents" "${EVENTS[i]}"
		else
			printf "\n%d) %s" "$indexEvents" "${EVENTS[i]}"
		fi
		((indexEvents++))
	done

	printf "\n%d) Quit to previous menu" "$((($totalEvents)+1))"
	printf "\n\nPlease select an option (1-%d)\n" "$((($totalEvents)+1))"
	
	read eventInput

	# associate LED with the selected system event
	if [[ ! $eventInput -gt $totalEvents ]] && [[ $eventInput -gt 0 ]]
	then
		((eventInput--))
		echo ${EVENTS[eventInput]} > trigger
		printf "\nLED is now associated with system event: %s\n" "${EVENTS[eventInput]}"
	elif [[ $eventInput = $(($totalEvents+1)) ]]
	then
		selectLed
		return 0
	else
		printf "\nPlease enter a correct input!\n"
		sysEvent
		return 0
	fi
	
	selectLed
}

function associate_led_perf(){

	local index=1
	local process
	local resource
	local curr_dir
	local pid
	local processIndex
	curr_dir=`pwd`

    printf "\nAssociate LED with the performance of a process"
    printf "\n------------------------------------------------"
    printf "\nPlease enter the name of the program to monitor(partial names are ok): \n"

    read process

	# change IFS to not split words due to spaces
	IFS=$'\t\n'

	# get processes inputted
	local processes=($(ps -e -o command | grep $process))

	unset $IFS

	local numProcesses=${#processes[@]}

	if [[ ! numProcesses -eq 0 ]]
	then
		# filter out "grep $process" from the process list
		((numProcesses--))
	fi

	if [[ numProcesses -eq 0 ]]
	then
		printf "\nNo process named %s has been found!" "$process"
		printf "\nPress enter to go back to previous menu...\n"
		read 
		selectLed 
		return
    elif [[ numProcesses -gt 1 ]]
	then
		# detect name conflict
		printf "\nName Conflict"
		printf "\n-------------"
		printf "\nI have detected a name conflict. Do you want to monitor:"

		for (( i=0; i<((numProcesses)); i++ ))
		do
			printf "\n%d) %s" "$index" "${processes[i]}"
			((index++))
		done

		printf "\n%d) Cancel Request" "$index"
		printf "\nPlease select an option (1 - %d):\n" "$index"

		read processIndex
		
		if [[ processIndex -eq index ]]
		then
			selectLed
			return 0
		elif [[ ! processIndex -gt index ]] && [[ processIndex -gt 0 ]]
		then
			((processIndex--))
			process=${processes[processIndex]}

			# get pid of the selected process
			pid=$(pidof $process)
		else
			printf "\nPlease enter a correct input!\n"
			read
			associate_led_perf 
			return 0
		fi
	else
		pid=$(pidof $process)
	fi

	printf "\nDo you wish to 1) monitor memory or 2) monitor cpu? [enter memory or cpu]:\n"

	read resource

	if [[ "$resource" = "memory" || "$resource" = "cpu" ]]
	then
		printf "\nstarting to monitor %s's $resource usage...\n" "$process"

		# disassociate LED with any system events
		echo none > trigger

		# execute background script, passing in relevant variables
		exec $bash_path $bgscript_path -m $resource -p $pid -l $curr_dir > $dev_null_path 2>&1 &
	else
		printf "\nPlease enter a correct input!\n"
		read
		associate_led_perf
		return 0
	fi
	
	selectLed 
}

function rootcheck(){
	# prevent users to run without SU permissions
	if [ "$EUID" -ne 0 ]
	then 
		printf "Please run the script as root/use sudo!\n"
		exit
	fi

	mainMenu
}

rootcheck
