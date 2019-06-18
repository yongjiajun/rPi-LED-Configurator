#!/bin/bash

# prevent the use of CTRL-C exit
trap '' 2 

# print usage if used incorrectly
function usage()
{
    # to use, type of performance, PID of the process and LED directory must be passed in as arguments
    echo "usage: sudo bgtask.sh -m [cpu/memory] -p [PID] -l [LED_DIR]"
}

# verify if arguments passed in aren't null
function verify(){
    if [[ -z "$led_dir" || -z "$mode" || -z "$pid" ]]
    then
        usage
        exit
    fi
    run
}

# monitor performance of selected process and update the selected LED
function run()
{
    local readIndex=1
    local hundred=100
    local input
    local usage

    cd $led_dir || exit

    # monitor CPU usage
    if [[ "$mode" = "cpu" ]]
    then
        # loops indefinitely until script gets killed
        while true 
        do
            # get cpu percentage
            input=($(ps -p $pid -o %cpu))
            usage=${input[readIndex]}

            echo CPU usage of $pid: $usage

            # turn on LED when CPU usage is not 0%
            if [[ $(echo "$usage == 0" | bc -l) == 0 ]]
            then
                echo 1 > brightness
                echo turned on
            fi

            # sleep for x milliseconds
            # usage is out of 100, then divided by 100 and sleep for that amount (max 1 second)
            sleep "$(echo "scale=2; $usage / $hundred" | bc)"
            
            # turn off LED when remaining CPU usage is not 0%
            if [[ $(echo "($hundred - $usage)  == 0" | bc -l) == 0 ]]
            then
                echo 0 > brightness
                echo turned off
            fi

            # sleep for x milliseconds
            # remaining usage minus usage is out of 100, then divided by 100 and sleep for that amount (max 1 second)
            sleep "$(echo "scale=2; ($hundred - $usage) / $hundred" | bc)"
        done
    # monitor memory usage
    elif [[ "$mode" = "memory" ]]
    then
        # loops indefinitely until script gets killed
        while true 
        do
            # get memory percentage
            input=($(ps -p $pid -o %mem))
            usage=${input[readIndex]}

            echo Memory usage of $pid: $usage

            # turn on LED when memory usage is not 0%
            if [[ $(echo "scale=2; $usage / $hundred | bc == 0" | bc -l) == 0 ]]
            then
                echo 1 > brightness
            fi

            # sleep for x milliseconds
            # usage is out of 100, then divided by 100 and sleep for that amount (max 1 second)
            sleep "$(echo "scale=2; $usage / $hundred" | bc)"

            # turn off LED when remaining memory usage is not 0%
            if [[ $(echo "scale=2; ($hundred - $usage) / $hundred == 0" | bc -l) == 0 ]]
            then
                echo 0 > brightness
            fi

            # sleep for x milliseconds
            # remaining usage minus usage is out of 100, then divided by 100 and sleep for that amount (max 1 second)
            sleep "$(echo "scale=2; ($hundred - $usage) / $hundred" | bc)"
        done
    fi
}

# getopts used to pass in arguments
while getopts ":m:p:l:" opt; do
  case $opt in
    m) readonly mode=$OPTARG ;;
    p) readonly pid=$OPTARG ;;
    l) readonly led_dir=$OPTARG ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# verify arguments passed in, if valid then run main function
verify
