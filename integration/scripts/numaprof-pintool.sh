#!/bin/bash
######################################################
#            PROJECT  : numaprof                     #
#            VERSION  : 0.0.0-dev                    #
#            DATE     : 07/2017                      #
#            AUTHOR   : Valat Sébastien  - CERN      #
#            LICENSE  : CeCILL-C                     #
######################################################

######################################################
NUMAPROF_PREFIX=
PINTOOL_PREFIX=
NUMAPROF_OPTIONS=""

######################################################
CALLGRIND=0
while true
do
	case "$1" in
		--callgrind)
			CALLGRIND=1
			shift
			;;
		--config|-c)
			export NUMAPROF_CONFIG="$2"
			shift 2
			;;
		--option|-o)
			export NUMAPROF_OPTIONS="${NUMAPROF_OPTIONS},$2"
			shift 2
			;;
		--dumpconfig|-d)
			export NUMAPROF_OPTIONS="${NUMAPROF_OPTIONS},output:config=true"
			shift 1
			;;
		-h|--help)
			echo "Usage : numaprof-pintool [--callgrind] [--config file] [--help] [--] YOUR_COMMAND"
			echo ""
			echo "Options:"
			echo "   --callgrind                 Enable conversion to kcachegrind format."
			echo "   -c file/--config file       Provide configuration file in INI format."
			#echo "           --mpi               Use MPI wrapper to get ranks in output file names."
			#echo "           --prep-mpi [mpicxx] Build the mpi wrapper into $HOME/.matt/libmattmpi.so"
			echo "   -d/--dumpconfig             Enable the dump of config file at exit."
			echo "   -o SEC:NAME=VAL;...         Override configuration values."
			echo "   -h/--help                   Show this help message."
			echo ""
			exit 0
			;;
		--)
			shift 1
			break
			;;
		*)
			break
			;;
	esac
done

######################################################
${PINTOOL_PREFIX}/pin -t ${NUMAPROF_PREFIX}/lib/libnumaprof-pintool.so -- "$@" &
pid=$!
wait $pid
status=$?

######################################################
#convert to callgrind format
if [ "$CALLGRIND" = "1" ]
then
	echo "Converting to callgrind...."
	${NUMAPROF_PREFIX}/bin/numaprof-to-callgrind numaprof-$pid.json > numaprof-$pid.callgrind
	rm numaprof-$pid.json
fi

######################################################
exit $status
