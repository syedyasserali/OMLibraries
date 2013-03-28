all: Makefile.numjobs config.done
	rm -rf build
	rm -f *.uses
	$(MAKE) all-work
	$(MAKE) test uses
	$(MAKE) debian
all-work: msl32 msl31 linearsystems msl222 msl16

config.done: Makefile
	which rm
	which svn
	which git
	which omc
	which debuild
	which dpkg-buildpackage
	which sha1sum
	which xargs
	which xsltproc
	touch config.done
Makefile.numjobs:
	echo 1 > $@
	echo "*** Warning: Setting number of jobs to 1. Slowness may ensue. ***"
msl32: config.done
	./update-library.sh SVN https://svn.modelica.org/projects/Modelica/trunk 6065 "MSL 3.2.1" all
	# Moving ModelicaReference so there is only one package for it
	for f in "build/ModelicaReference 3.2.1"*; do mv "$$f" "`echo $$f | sed 's/ 3.2.1//'`"; done
msl31: config.done
	./update-library.sh SVN https://svn.modelica.org/projects/Modelica/branches/maintenance/3.1 5515 "MSL 3.1" Modelica ModelicaServices
msl222: config.done
	./update-library.sh --encoding "Windows-1252" --std "2.x" --license "modelica1.1" SVN https://svn.modelica.org/projects/Modelica/branches/maintenance/2.2.2 6145 "MSL 2.2.2" all
msl16: config.done
	./update-library.sh --license "modelica1.1" --std "1.x" SVN https://svn.modelica.org/projects/Modelica/tags/V1_6 939 "MSL 1.6" "Modelica 1.6"

linearsystems: config.done
	./update-library.sh SVN https://svn.modelica.org/projects/Modelica_EmbeddedSystems/trunk 6147 "Modelica_EmbeddedSystems" Modelica_LinearSystems2
#diff-linearsystems:
#	./diff-library.sh "Modelica_EmbeddedSystems/Modelica_LinearSystems2/" "Modelica_LinearSystems2 2.3" "Modelica_LinearSystems2 2.3.patch"

test: config.done
	rm -f error.log test-valid.*.mos
	find build/*.mo build/*/package.mo -print0 | xargs -0 -n 1 -P `cat Makefile.numjobs` sh -c './test-valid.sh "$$1"' sh
	rm -f error.log test-valid.*.mos
uses: config.done
	find build/*.uses -print0 | xargs -0 -n 1 -P `cat Makefile.numjobs` sh -c './check-uses.sh "$$1"' sh
debian: config.done
	find build/*.hash -print0 | xargs -0 -n 1 -P `cat Makefile.numjobs` sh -c './debian-build.sh "$$1"' sh

clean:
	rm -f *.rev *.uses  test-valid.*.mos config.done
	rm -rf "MSL 3.2.1" "MSL 2.2.2" "MSL 3.1" "Modelica_EmbeddedSystems" "Modelica_LinearSystems2 2.3"
