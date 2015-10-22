chiselVersion	?= 2.3-SNAPSHOT
SBT		?= sbt
SBT_FLAGS	?= -Dsbt.log.noformat=true -DchiselVersion=$(chiselVersion)
TARGETDIR ?= ./target
# NOTE: As of 10/22/2015 and Chisel v2.2.30 with the new memory mapped Tester,
#       the runtime tests hang after the initial startup dialog.
#       This appears to be some sort of race condition since makeing almost
#       any chang (delete either "--parallelMakeJobs -1" or "--compileInitializationUnoptimized"
#       or reording the sequence of "check" tests, or compiling with "-O0",
#       seems to "fix" the problem.
# The following need to be specified as pairs due to OpenSoC's argument parsing
# The arguments that are really Chisel booleans will ignore the second (dummy) value
SPECIAL_CHISEL_FLAGS ?= --parallelMakeJobs -1 --compileInitializationUnoptimized - --lineLimitFunctions 1024 --minimumLinesPerFile 32768 --targetDir $(TARGETDIR)
OPENSOC_FLAGS	?= --harnessName OpenSoC_CMeshTester_Random_VarInjRate --moduleName OpenSoC_CMesh_Flit

.PHONY:	smoke publish-local check clean jenkins-build

default:	publish-local

smoke:
	$(SBT) $(SBT_FLAGS) compile

publish-local:
	$(SBT) $(SBT_FLAGS) publish-local

check:
	$(SBT) $(SBT_FLAGS) "run --sw true $(OPENSOC_FLAGS) $(SPECIAL_CHISEL_FLAGS)"
	$(SBT) $(SBT_FLAGS) "run --hw true $(OPENSOC_FLAGS) $(SPECIAL_CHISEL_FLAGS)"

clean:
	$(SBT) $(SBT_FLAGS) clean
	for dir in $(CLEAN_DIRS); do $(MAKE) -C $$dir clean; done
	$(RM) -r $(RM_DIRS)

jenkins-build: clean check publish-local

