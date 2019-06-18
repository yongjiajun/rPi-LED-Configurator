This was an assignment on Bash/shell scripting for my Unix/Linux System Administration and Programming class.

---------------------------
s3688090's Led_Konfigurator
---------------------------


CONTENTS OF THIS FILE
---------------------
   
 * Introduction
 * Requirements
 * Instructions
 * Troubleshooting
 * FAQ
 * Maintainers


INTRODUCTION
------------

s3688090's Led_Konfigurator is a script that allows users to configure the LEDs on their Raspberry Pi as well as the LEDs on their connected peripherals such as keyboards. 

Features include:

- Turning on and off an LED
- Associate LED with a system event
- [Buggy] Associate LED with the performance of a process, turns on LED for accordingly to CPU/memory usage
	- LED works as an event timer in this mode, if CPU/memory usage if 50% the LED will be turned on for 0.5s and off for 0.5s.

There are 2 scripts that come with the package.

- ledconfig.sh : main script responsible displaying menus and perform LED manipulation.

- bgtask.sh : background script that monitors performance of a specified process and updates the LED


REQUIREMENTS
------------

A Raspberry Pi running Bash shell is required to execute the script script. SU's permissions will be required to perform LED manipulations.


INSTRUCTIONS
------------

1. To run the script:

- Open terminal running Bash shell and "cd" to the package's folder.
- Enter "sudo bash ledconfig.sh" or "bash ledconfig.sh" if running as root user.
- Enter your password if running on non-root user to obtain SU's permissions.

2. To turn on and off an LED:

- At the main menu, select an LED.
- Use either of the "1) turn on" or "2) turn off" options.

3. To associate an LED with a system event:

- At the main menu, select an LED.
- Select the "3) associate with a system event" option.
- Select one of the system events to associate the LED with it.

4. To associate LED with the performance of a process:

- At the main menu, select an LED.
- Select the "4) associate with the performance of a process" option.
- Enter the name of the program to monitor (partial names are fine).
- If a name conflict is detected, select the specific program to monitor.
- Choose to monitor either memory or CPU usage.
- The background script will run to handle the task.

5. To stop association with a process' performance:

- At the main menu, select the LED used to associate with the performance of a process.
- Select the "5) stop association with a process' performance" option.
- The background script will stop running.


TROUBLESHOOTING
---------------

1. I keep getting this "Please run the script as root/use sudo!" message. How is that?

- As the message says, please run the script as root or use sudo!!!!!!!!!!!!!!!!!!

2. Sometimes the LED doesn't refresh quick enough when monitoring a process' performance.

- Unfortunately this is due to hardware's limitation, therefore the LED won't update fast enough regardless of the resource usage.



MAINTAINERS
----------

Current maintainer:
* Jia Jun Yong (s3688090) - https://github.com/rmit-s3688090-yongjiajun / https://github.com/yongjiajun

This project has been sponsored by:
* RMIT University
	I was joking.