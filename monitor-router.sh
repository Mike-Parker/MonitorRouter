#!/bin/sh

./query_router.pl |\
./driveGnuPlotStreams.pl 6 3 120 120 120 \
			 0 10 0 100 0 54 \
			 500x300+0+0 500x300+530+0 500x300+0+385 \
			 'WAN Rx' 'WAN Tx' 'LAN Rx' 'LAN Tx' 'WLAN Rx' 'WLAN Tx' \
			 0 0 1 1 2 2
