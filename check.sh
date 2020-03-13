export PATH=$PATH:/u/s/i/sinclair/public/html/courses/cs552/spring2020/handouts/bins
#cp /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/verilog_code/Vcheck.class ./
#cp /u/s/i/sinclair/public/html/courses/cs552/spring2019/handouts/verilog_code/VerFile.class ./
read -p "demo: input only the number: " demo
read -p "Run test? 1 for yes 0 for no: " runTest
# read -p "net id: input your netid: " nid
cd demo$demo
mkdir -p summary
cd verilog
if [ "$runTest" == "1" ]
then
	# run test
	wsrun.pl -list /u/s/i/sinclair/courses/cs552/spring2020/handouts/testprograms/public/inst_tests/all.list proc_hier_bench *.v 
	mv summary.log simple.summary.log
	wsrun.pl -list /u/s/i/sinclair/courses/cs552/spring2020/handouts/testprograms/public/complex_demo$demo/all.list proc_hier_bench *.v 
	mv summary.log complex.summary.log
	wsrun.pl -list /u/s/i/sinclair/courses/cs552/spring2020/handouts/testprograms/public/rand_simple/all.list proc_hier_bench *.v 
	mv summary.log rand_simple.summary.log
	wsrun.pl -list /u/s/i/sinclair/courses/cs552/spring2020/handouts/testprograms/public/rand_complex/all.list proc_hier_bench *.v 
	mv summary.log rand_complex.summary.log
	wsrun.pl -list /u/s/i/sinclair/courses/cs552/spring2020/handouts/testprograms/public/rand_ctrl/all.list proc_hier_bench *.v 
	mv summary.log rand_ctrl.summary.log
	wsrun.pl -list /u/s/i/sinclair/courses/cs552/spring2020/handouts/testprograms/public/rand_ctrl/all.list proc_hier_bench *.v 
	mv summary.log rand_mem.summary.log
	mv *.summary.log ../summary/
fi
rm -f *.img, *.img.reg, *.img.dmem, *.trace, *.out, *.ptrace, *.wlf, *.vcd *.lst *.log transcript 
rm -rf __work
name-convention-check
vcheck-all.sh
for file in *.vcheck.out
do
	head -n1 $file
	tail -n1 $file
done
cd ../..
tar -czvf "demo"$demo".tgz" demo$demo
python3 /u/s/i/sinclair/public/html/courses/cs552/spring2020/handouts/scripts/project/phase$demo/verify_submission_format.py "demo"$demo".tgz"
rm -f topdir.txt

