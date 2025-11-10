source /tools/script/bashrc_ius_15.2.08
source /tools/script/src_iccr_imc

if [[ -d INCA_libs ]];
then
    rm -r ./INCA_libs/
fi

rm irun.*

if [[ -d waves.shm ]];
then
    rm -r ./waves.shm/
fi

if [[ -d cov_work ]];
then
    if [ $3 != "cov_merge_exclude" ]; then
        rm -r ./cov_work/
    fi
fi

#------- Create a Test List --------#
#filenames=`ls ../tb/test/*_test.sv`

declare -a test_array
declare -a array1
declare -a array2
declare -a array3

# insert the test names where assertions will turn off
array3=(APB_I2C_MT_cov_test APB_I2C_master_reset_test APB_I2C_register_test APB_I2C_M_arbitration_SLA_WR_lost_test APB_I2C_M_arbitration_in_data_transfer_lost_test APB_I2C_M_on_the_fly_error_test APB_I2C_M_on_the_fly_EN_low_test)

# all test names
array1=(APB_I2C_master_reset_test APB_I2C_register_test APB_I2C_MT_write_transfer_with_S_test APB_I2C_MT_write_transfer_with_P_follow_S_test APB_I2C_MT_next_write_transfer_with_RS_test APB_I2C_MT_write_transfer_with_slave_NACK_test APB_I2C_MR_read_transfer_with_S_test APB_I2C_MR_read_transfer_with_P_follow_S_test APB_I2C_MR_next_read_transfer_with_RS_test APB_I2C_MR_read_transfer_with_slave_NACK_test APB_I2C_M_randomize_test APB_I2C_M_arbitration_SLA_WR_win_test APB_I2C_M_arbitration_SLA_WR_lost_test APB_I2C_M_arbitration_in_data_transfer_win_test APB_I2C_M_arbitration_in_data_transfer_lost_test APB_I2C_M_synchronization_test APB_I2C_M_clock_stretching_test APB_I2C_M_write_collision_test APB_I2C_MT_cov_test)

if [ $3 == "gui" ]; then
  for j in ${array3[@]}
  do
    if [ $j == $1 ]
    then
      def="assert_off"
      break
    else
      def="assert_on"
    fi
  done
  irun -f filelist.f -gui -access +rwc -uvm +UVM_NO_RELNOTES -timescale 1ns/1ps +UVM_TESTNAME=$1 +UVM_VERBOSITY=$2 +test_itter=$4 -define $def -seed random
elif [ $3 == "cov_1" ]; then
  cp -R ./cov_work/ ./cov_files/
  for j in ${array3[@]}
  do
    if [ $j == $1 ]
    then
      def="assert_off"
      break
    else
      def="assert_on"
    fi
  done
  irun -f filelist.f -uvm +UVM_NO_RELNOTES -timescale 1ns/1ns +UVM_TESTNAME=$1 +UVM_VERBOSITY=$2 -coverage all -covtest $1 -covfile ccffile.ccf +test_itter=$4 -define $def -seed random
  cp ./irun.log ./log_files/$1.log
  iccr iccr_single_cov.cmd
  firefox html*/index.html &
elif [ $3 == "cov_all" ]; then
  for i in $array1
  do   
    def="assert_on"
    for j in ${array3[@]}
    do
      if [ $j == $i ]
      then
        def="assert_off"
      else
        continue
      fi
    done
    irun -f filelist.f -uvm +UVM_NO_RELNOTES -timescale 1ns/1ns +UVM_TESTNAME=$i +UVM_VERBOSITY=$2 -coverage all -covtest $i -covfile ccffile.ccf +test_itter=$4 -define $def -seed random
    cp ./irun.log ./log_files/$i.log	
  done	
  iccr iccr_merge_cov.cmd
  firefox html*/index.html &
elif [ $3 == "cov_merge_exclude" ]; then
  echo "========== Selected Test with Coverage Merge Mode Called (Excluding Signals from given list) ==========";	
  #------- Copy the cov_work folder inside cov_file --------#	
  cp -R ./cov_work ./cov_files/
  #------- Remove the cov_work folder --------#	
  cov_remover
  #------- Create a Test List --------#
  mapfile test_array < test_list.txt
  for i in $test_array
  do   
    def="assert_on"
    for j in ${array3[@]}
    do
      if [ $j == $i ]
      then
        def="assert_off"
      else
        continue
      fi
    done  
    irun -f filelist.f -uvm +UVM_NO_RELNOTES -timescale 1ns/1ns +UVM_TESTNAME=$i +UVM_VERBOSITY=$2 -coverage all -covtest $i -covfile ccffile.ccf +test_itter=$4 -define $def -seed random 
    cp ./irun.log ./log_files/$i.log
  done
  #------- Merge the previous cov_work with latest cov_work --------#	
  cp -R ./cov_files/cov_work/scope ./cov_work/		
  iccr iccr_merge_cov.cmd
  firefox html*/index.html &  
else
  irun -f filelist.f -access +rwc -uvm +UVM_NO_RELNOTES -timescale 1ns/1ns +UVM_TESTNAME=$1 +UVM_VERBOSITY=$2 +test_itter=$4 -seed random
fi


