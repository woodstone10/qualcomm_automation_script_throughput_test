###########################################################################################
#
# AutomaticDataThroughputTestScript.pl
#
# General description: 
# During the data throughput test in commercial network, 
# the tester sometimes should capture the various kind of logs 
# such as QXDM, ADB TCP dump and Wireshark data log to analyze issue. 
# Also the saving of all logs for each count is required to compare two logs 
# and discover the differences or similarities between a low and high performance throughput.
# Most engineers have conducted the test and log capturing manually until now. 
#
# About this software:
# This sample code introduces to do test and save logs automatically,
# by enable automatic connects to FTP server and start download/upload (=get/put) file. 
# At the same time, it captures the various kind of logs what tester needs for each test count. 
# This automatic script can make tester free without user activity 
# and eliminates inappropriate log capturing 
# and leads the way to capture the various kind of logs properly. 
# In addition, the test result file will be created automatically 
# and this is very useful when put the time to test workbook. 
# 
# ex) DOS command
# FTP_VzWIrvineFTPget.txt
# ------------------------
# open 198.224.169.244 
# ftp781 
# 4aTvHt*J 
# bi 
# hash 
# bell 
# cd download 
# get down_200M.zip
# bye
# ------------------------
#
# How to use it: 
# << Prepare to Test >>
# 1. Connect the device to your PC
# 2. If you want to capture ADB TCP dump log, you need to run 'adb root' first in DOS console before connect tethering. 
#	ADB root is required at one time until reboot the device. 
# 3. Connect Tethered Mode
#   USB Connection as Ethernet
#	In case of USB Tethered mode, Mobile Broadband Connect ON
#	In case of Mobile Hotspot mode, Mobile Hotspot ON
# 4. Before start testing, you should find the port number. 
#	(1) QXDM Port - You can check this through QPST Configuration or Device Manager 
#		and the COM port for QXDM should be added in QPST Configuration like below before running the script.
#	(2)	Wireshark Port - You can check the name of the network interface 
#		through 'Wireshark Capture Interfaces' (Press Ctrl+I keys on Wireshark) 
#		The used network interface can be distinguish from others by seeing the Packets column. 
#		Note: Wireshark sometimes can not find the port number of network access after tethering connection. 
#		For this case, the reboot your PC would solve this problem.
# << Execute to Test >>
# 5. Execute AutomaticDataThroughputTestScript.pl      
#	There are two ways to execute the test script. 
#	One is type 'perl AutomaticDataThroughputTestScript.pl' on DOS console 
#	or simple double click AutomaticDataThroughputTestScript.pl file.
# 6. Fill and Answer about some questions   
#	(Q1) Type Comport number:
#	(A1) Please type QXDM port number (Please refer to Step 4)
#	(Q2) Type tshark interface number:
#	(A2) Please type Wireshark port number (Please refer to Step 4)
#	(Q3) Type Mode Name:
#	(A3) Please type your device name. For example, I415, MHS291, VK410, VS880 and so on.
#	(Q4) Type your special test condition (if not, just Type normal or Press Enter) :
#	(A4) Please type the test condition. 
#		For example, normal, power-up, position_reverse and so on. 
#		You can also press Enter key if you do not want type special condition.
#	(Q5) Select Location (1:Dallas, 2:Irvine, 3:LGTestBed, 4:ftp.lgmobilecomm.com) :
#	(A5) Type 1 or 2. 1 is for Dallas LTE FTP server and 2 is for Irvine LTE FTP server.
#	(Q6) Select Band (1:Band13, 2:Band4) :
#	(A6) Type 1 or 2. 1 is for LTE Band 13 and 2 is for LTE Band 4.
#	(Q7) Select UTM or MHS (1:UTM, 2:MHS, 3:SVLTE) :
#	(A7) Type 1, 2 or 3. 1 is for USB Tethered mode, 2 is for Mobile HotSpot mode and 3 is for SVLTE mode.
#	(Q8) Select Download or Upload (1:Download, 2:Upload) :
#	(A8) Type 1 or 2. 1 is for Download test and 2 is for Upload test
#	(Q9) Type Start Count:
#	(A9) Please type the count number of starting test. You would normally type 1 as starting count.
#	(Q10) Type End Count:
#	(A10) Please type the count number of ending test. You would normally type 15 as ending count.
#	(Q11) Do you want tcpdump log? (1:Yes, 2:No) :
#	(A11) Type 1 or 2. For case of 1, ADB TCP dump log will be saved on your PC. 
#	(Q12) Do you want tshark log? (1:Yes, 2:No) :
#	(A12) Type 1 or 2. For case of 1, Wireshark log will be saved on your PC. (Please refer to Step 4 and Q2)
#	Example : Band 13 UTM Download Testing in Dallas market. Please fine attched screen capture picture.
# 7. Test in progress...
# 8. After all test are finished as you put the count (End Count A10 - Start Count A9), 
#	all logs and test results are saved in one folder which is created as following the above your answers.   
#	The rule of making the folder name is "Location(A5)_Band(A6)_Mode(A7)_Test(A8)_Model_Name(A3)_Special_Condition(A4)". 
# 	The file with the extension of _qxdm.isf is QXDM modem log.
#	The file with the extension of _tcpdump.pcap is ADB TCP dump log.
#	The file with the extension of _tshark.pcap is Wireshark data log.
#	In this folder, there are two text files. 
#	One is the saved DOS console output text, named as "folder_name_CMD_start#_end#.txt". 
#	The other is the test result with marked in second unit, named as "folder_name_TR_start#_end#.txt".  
#	The test result file is very useful when put the time to FIT workbook.
#
# Pre-install required:
# 1. Qualcomm QXDM 
# 2. Google Anroid ADB
# 3. Wireshark (Tshark) - Add Wireshark path to Environment Variables of your PC
# 4. Perl Software
#
# NOTE: This script must be run from a command box, 
# >> Perl AutomaticDataThroughputTestScript.pl
#
# Created by Jonggil Nam
# https://www.linkedin.com/in/jonggil-nam-6099a162/ | https://github.com/woodstone10 | woodstone10@gmail.com | +82-10-8709-6299 
###########################################################################################

use HelperFunctions;
use Time::Local;
use Cwd;
use File::Path;
use File::Copy;

my $QXDM;
my $MODEL_ID;
my $COMPORT_NUM;
my $ITERATION_CNT;
my $ERROR_CEHCK = 0;
my $SEL = 0;

sub Initialize
{
   # Assume failure
   my $RC = false;

   # Create QXDM object
   $QXDM = new Win32::OLE 'QXDM.Application';
   if ($QXDM == null)
   {
      print "\nError launching QXDM";
   }

   SetQXDM( $QXDM );

   # Success
   $RC = true;
   return $RC;
}

# Dump out and change QXDM server's visibility status
sub Visible
{
   # QXDM server's visible status
   my $VisibleValue = $QXDM->{Visible};
   if ($VisibleValue == false)
   {
      print "\nQXDM is currently not visible\n"
          . "Making QXDM server visible\n";

      # Make QXDM server visible
      $QXDM->{Visible} = true;

      print "QXDM server now visible\n";

      return;
   }

   print "\nQXDM is currently visible"
       . "\nMaking QXDM server unvisible\n";
}

 # input Test Related Info
 sub GetTestInfo
 {
    $ERROR_CEHCK = 0;

    system "tshark-D.bat";      
    
    print "\nType Comport number: ";
    $COMPORT_NUM = <STDIN>;
    chomp($COMPORT_NUM);
    foreach ($COMPORT_NUM) {
        if ( /[^0-9.]/ ) {
            $ERROR_CEHCK++;
            print "Error! $_ \tis not numeric\n";
        }    
    }

    print "Type tshark interface number: ";
    $TSHARK_INTERFACE_NUM = <STDIN>;
    chomp($TSHARK_INTERFACE_NUM);
    foreach ($TSHARK_INTERFACE_NUM) {
        if ( /[^0-9.]/ ) {
            $ERROR_CEHCK++;
            print "Error! $_ \tis not numeric\n";
        }    
    }
    
    print "Type Model Name: ";
    $MODEL_ID = <STDIN>;
    chomp($MODEL_ID);

    print "Type your special test condition (if not, just Type normal or Press Enter) : ";
    $SPECIAL_CONDITION = <STDIN>;
    chomp($SPECIAL_CONDITION);

    print "Select Location (1:Dallas, 2:Irvine, 3:LGTestBed, 4:ftp.lgmobilecomm.com) : ";
    $LOCATION_ID = <STDIN>;
    chomp($LOCATION_ID);
    if($LOCATION_ID ne 1  && $LOCATION_ID ne 2 && $LOCATION_ID ne 3 && $LOCATION_ID ne 4) { 
        $ERROR_CEHCK++;
        print "Error! Unknown Location\n";    
    }

    print "Select Band (1:Band13, 2:Band4) : ";
    $BAND_ID = <STDIN>;
    chomp($BAND_ID);
    if($BAND_ID ne 1  && $BAND_ID ne 2) { 
        $ERROR_CEHCK++;
        print "Error! Unknown Band\n";    
    }

    print "Select UTM or MHS (1:UTM, 2:MHS, 3:SVLTE) : ";
    $TETHERED_ID = <STDIN>;
    chomp($TETHERED_ID);
    if($TETHERED_ID ne 1  && $TETHERED_ID ne 2 && $TETHERED_ID ne 3) { 
        $ERROR_CEHCK++;
        print "Error! Unknown Tethermode\n";    
    }

    #print "Select Download or Upload (1:Download, 2:Upload) : ";
    print "Select Download or Upload (1:Download, 2:Upload) : ";
    $ITEM_ID = <STDIN>;
    chomp($ITEM_ID);   
    if($ITEM_ID ne 1  && $ITEM_ID ne 2) { 
        $ERROR_CEHCK++;
        print "Error! Unknown Test Item\n";    
    }

    # start count
    print "Type Start Count: ";
    $START_CNT = <STDIN>;
    chomp($START_CNT);
    foreach ($START_CNT) {
        if ( /[^0-9.]/ ) {
            $ERROR_CEHCK++;
            print "Error! $_ \tis not numeric\n";
        }
    }

    # end count
    print "Type End Count: ";
    $END_CNT = <STDIN>;
    chomp($END_CNT);
    foreach ($END_CNT) {
        if ( /[^0-9.]/ ) {
            $ERROR_CEHCK++;
            print "Error! $_ \tis not numeric\n";
        }
    }

=pod    
    print "Type Number of Tests to Excute: ";
    $ITERATION_CNT = <STDIN>;
    chomp($ITERATION_CNT);
    foreach ($ITERATION_CNT) {
        if ( /[^0-9.]/ ) {
            $ERROR_CEHCK++;
            print "Error! $_ \tis not numeric\n";
        }
    }
=cut

    print "Do you want tcpdump log? (1:Yes, 2:No) : ";
    $TCPDUMP_LOG = <STDIN>;
    chomp($TCPDUMP_LOG);
    if($TCPDUMP_LOG ne 1  && $TCPDUMP_LOG ne 2) { 
        $ERROR_CEHCK++;
        print "Error! Unknown tcpdump log option\n";    
    }

    print "Do you want tshark log? (1:Yes, 2:No) : ";
    $TSHARK_LOG = <STDIN>;
    chomp($TSHARK_LOG);
    if($TSHARK_LOG ne 1  && $TSHARK_LOG ne 2) { 
        $ERROR_CEHCK++;
        print "Error! Unknown tshark log option\n";    
    }
    
    return;
 }
 
# Obtain and dump out the COM port status¤·
sub DumpCOMPort
{
   # Check COM port status
   my $COMPort = $QXDM->COMPort;
   if ($COMPort == -1)
   {
      print "QXDM COM Port Error occurred\n";
   }
   elsif ($COMPort == 0)
   {
      print "QXDM COM Port Disconnected state\n";
   }
   elsif ($COMPort > 0)
   {
      print "Connected to port: COM" . $COMPort . "\n";
   }
}

sub SetCOMPort
{
	# Change the COM port
	$QXDM->{COMPort} = $COMPORT_NUM;

	# Wait for change in COM port
	sleep( 2 );

	# Obtain and dump out the COM port status
	DumpCOMPort();
}
 
sub FileNamewithTime
{
   my $FileName = "";

   if (length( $Path ) <= 0)
   {
      # Use script path
      $Path = GetPathFromScript();
   }

   #  Get GM time string (Wed May 31 03:03:22 2006)
   my $tm = gmtime();

   # Remove whitespace and replace ':' with '.'
   $tm =~ s/\:/\./g;
   my @a = split( / /, $tm );

   # Rearrange date
   #my $TodaysDate = "$a[0]_$a[2]_$a[1]_$a[4]_$a[3]_UTC";
   my $TodaysDate = "$a[0]_$a[2]_$a[1]";
   $FileName = $TodaysDate;

   return $FileName;
}


sub convert
{
    my $dstring = shift;

    my %m = ( 'Jan' => 0, 'Feb' => 1, 'Mar' => 2, 'Apr' => 3,
            'May' => 4, 'Jun' => 5, 'Jul' => 6, 'Aug' => 7,
            'Sep' => 8, 'Oct' => 9, 'Nov' => 10, 'Dec' => 11 );

    if ($dstring =~ /(\S+)\s+(\d+)\s+(\d{2}):(\d{2}):(\d{2})/)
    {
        my ($month, $day, $h, $m, $s) = ($1, $2, $3, $4, $5);
        my $mnumber = $m{$month}; # production code should handle errors here

        timelocal( $s, $m, $h, $day, $mnumber, Year - 1900 );
    }
    else
    {
        die "Format not recognized: ", $dstring, "\n";
    }
}

# Main body of script

#adb root first
#connect tethering
#run this program


$ProgramDir = getcwd();
chdir($ProgramDir);

sub Execute
{
   my $FILENAME;
   my $ITERATION = 0;

   $location = "Unknown";
   $band = "Unknown";
   $item = "Unknown";
   $tethered = "Unknown";

   # Launch QXDM
   #print "\QXDM Initialize";
   my $RC = Initialize();
   if ($RC == false)
   {
      return;
   }

   # Get QXDM version
   #my $Version = $QXDM->{AppVersion};
   #print "\nQXDM Version: " . $Version. "\n";

   # Dump out and change QXDM visibility status
   #Visible();

   # input Test Related Info
   GetTestInfo();


   if( $TCPDUMP_LOG eq 1)
   {
       system "initADB.bat";   
       #@echo off
       #adb kill-server
       #adb devices
       #adb root && adb wait-for-device
       sleep(1);    
   }   


if( $ERROR_CEHCK eq 0)
{
   ##
   ## FILE NAME & TEST SELECTION
   ##       
   if($LOCATION_ID eq 1){ $location = "Dallas"; }
   elsif($LOCATION_ID eq 2){ $location = "Irvine"; }
   elsif($LOCATION_ID eq 3){ $location = "LGTestBed"; }
   elsif($LOCATION_ID eq 4){ $location = "ftp.lgmobilecomm.com"; }
   else{ die "Error! Unknown Location"  }

   if($BAND_ID eq 1){ $band= "Band13"; }
   elsif($BAND_ID eq 2){ $band = "Band4"; }
   else{ $band = "Unknown"; }

   if($TETHERED_ID eq 1){ $tethered= "UTM"; }
   elsif($TETHERED_ID eq 2){ $tethered = "MHS"; }
   elsif($TETHERED_ID eq 3){ $tethered = "SVLTE"; }
   else{ $tethered = "Unknown"; }

   
   # USE FOR VZW FIT
   if($ITEM_ID eq 1)
   {
        $item= "Download";
        if($LOCATION_ID eq 1){  
            #system "VzWDallasFTPget.bat";  
            $SEL = 1;
            }
        elsif($LOCATION_ID eq 2){ 
            #system "VzWIrvineFTPget.bat"; 
            $SEL = 2;
            }     
   }
   elsif($ITEM_ID eq 2)
   {
        $item = "Upload";
        if($LOCATION_ID eq 1){  
            #system "VzWDallasFTPput.bat";  
            $SEL = 3;
            }
        elsif($LOCATION_ID eq 2){ 
            #system "VzWIrvineFTPput.bat"; 
            $SEL = 4;
            }
   }
   else
   {
        $SEL = 0;
   }

   # USE FOR TESTBED and WIRELINE    
   if($LOCATION_ID eq 3){ $SEL = 5; } #LG TEST BED
   if($LOCATION_ID eq 4){ $SEL = 6; } #WIRELINE 

  
   
   #$TESTNAME = $MODEL_ID."_".$location."_".$band."_".$tethered."_".$item."_".$SPECIAL_CONDITION;
   if($SPECIAL_CONDITION eq "")
   {
        $TESTNAME = $location."_".$band."_".$tethered."_".$item."_".$MODEL_ID;
   }
   else
   {
        $TESTNAME = $location."_".$band."_".$tethered."_".$item."_".$MODEL_ID."_".$SPECIAL_CONDITION;
   }
   $QXDM->QXDMTextOut( $TESTNAME );
   #print "\nAdding 'Test string' to QXDM item store\n";   
   print "\nLOG FILE : $TESTNAME\n";

   # make log folder
   $OUT_FOLDER = "$ProgramDir\\$TESTNAME";
   if($OUT_FOLDER < 30050)
   {
   mkdir($OUT_FOLDER, 0700);
   }
      
   SetCOMPort();   
   sleep(1);
   
   $QXDM->LoadConfig(GetPathFromScript()."LTE_Throughput.dmc");   
   sleep(1);
   
   $QXDM->CreateView( "Item View", "" );   
   sleep(1);

   #while($ITERATION_CNT>$ITERATION)
   for($ITERATION=$START_CNT; $ITERATION<$END_CNT+1; $ITERATION++)
   {
       #$ITERATION++; 

       # file name define
       $FILENAME = $TESTNAME."_".$ITERATION;       
       #$FILENAME = "$OUT_FOLDER\\$FILENAME";       
       $TCPDMUP_FILENAME = $FILENAME."_tcpdump".".pcap";
 	   $TSHARK_FILENAME = $FILENAME."_tshark".".pcap";
       #$QXDM_FILENAME = GetPathFromScript().$MODEL_ID."_".$location."_".$band."_".$tethered."_".$item."_".$SPECIAL_CONDITION."_".$ITERATION."_".FileNamewithTime().".isf";
       $QXDM_FILENAME = GetPathFromScript().$FILENAME."_qxdm".".isf";
       $QXDM_FILE = $FILENAME."_qxdm".".isf";
       #$CMD_OUTOUT_FILENAME = GetPathFromScript().$TESTNAME."_Cmd_Output_".FileNamewithTime().".txt" ;
       #$THROUGHPUT_RESULT_FILENAME = GetPathFromScript().$TESTNAME."_Test_Result_".FileNamewithTime().".txt" ;
       #$CMD_OUTOUT_FILENAME = $TESTNAME."_CMD".".txt" ;
       #$THROUGHPUT_RESULT_FILENAME = $TESTNAME."_TR".".txt" ;

       $CMD_OUTOUT_FILENAME = $TESTNAME."_CMD_"."$START_CNT"."_"."$END_CNT".".txt" ;
       $THROUGHPUT_RESULT_FILENAME = $TESTNAME."_TR_"."$START_CNT"."_"."$END_CNT".".txt" ;

       
       $start_time = localtime;
       print "Start : $start_time\n";

       $QXDM->{Visible} = TRUE;       
       $QXDM->ClearViewItems( "Item View" );
 	   $QXDM->QXDMTextOut( $FILENAME );
       
       ##
       ## ACTION FTP DOWNLOAD/UPLOAD !!
       ##

       ##CASE 1 : Original
       #system "FTP_Automation.bat"; 
       #=> display cmd output and display throughput but NOT save txt file

       ##CASE 2 : Save TXT using tee file 
       #system "FTP_Automation_tee.bat $cmdOutput_file.txt"; 
       #=> display cmd output and save txt file but NOT display throughput
       #=> NOT work + option =>SOLVE this problem using -a option

       ##CASE 3 : Save TXT using btee file       
       #system "FTP_Automation_batchTee.bat $cmdOutput_file.txt"; 
       #=> display cmd output and save txt file but NOT display throughput
       #=> WORK + option
       
       ##CASE 4 : Save TXT using wtee file       
       system "FTP_Automation.bat $SEL $CMD_OUTOUT_FILENAME $TSHARK_FILENAME $TCPDUMP_LOG $TSHARK_LOG $TSHARK_INTERFACE_NUM";       
       #=> display cmd output and save txt file and display throughput
       #=> WORK + =>-a option

       ##CASE 5 : Save TXT using perl qx command
       #my $output = qx(FTP_Automation.bat);
       #open my $OUTPUT, '>', 'output.txt' or die "Couldn't open output.txt: $!\n";
       #print $OUTPUT $output;
       #close $OUTPUT;

       ##CASE 6 : 
       #system "FTP_Automation.bat >out.txt 2>&1"; 
       #=> only save txt file (not display cmd output) and NOT display throughput

       ##CASE 7: 
       #open (my $file, '>', 'output.txt');
       #print $file `FTP_Automation.bat`;
       #=> only save txt file (not display cmd output) and NOT display throughput


       #STOP ==>ALL NOT WORKING
       #print $telnet->cmd("\x03");
       #Send("^c");
       #ProcessClose("tcpdump.bat") ;
       #$SIG{INT} = sub { print STDERR "Control-C"; };
       #$SIG{QUIT} = sub { print STDERR "Control-"; };
       #sleep 30;


       $end_time = localtime;
       print "Finish : $end_time\n";  
       print "Diff (seconds) = ", convert($end_time) - convert($start_time), "\n";                    
       #print "Test Count = $ITERATION of $ITERATION_CNT\n";
       print "Test Count = $ITERATION of $END_CNT\n";

       # wait for closing
       sleep(1);


       #chdir($OUT_FOLDER);
        
       # please keep the order : tshark -> QXDM -> tcpdump
       #STEP 1 : SAVE TSHARK (WIRESHARK)
       if( $TSHARK_LOG eq 1)
       {
        system "tshark-s.bat";  
        #move("$ProgramDir/$TSHARK_FILENAME", "$OUT_FOLDER/$TSHARK_FILENAME");
       }

       #STEP 2 : SAVE QXDM       
       $QXDM->QXDMTextOut( $FILENAME );
       $QXDM->CopyViewItems("Item View",$QXDM_FILENAME);               
       $QXDM->CreateView( "Item View", "" );
       $QXDM->{Visible} = FALSE;       
       #move("$ProgramDir/$QXDM_FILE", "$OUT_FOLDER/$QXDM_FILE");
       
       #STEP 3 : SAVE TCPDUMP
       if( $TCPDUMP_LOG eq 1)
       {
        system "tcpdump-s.bat $TCPDMUP_FILENAME";  
        #move("$ProgramDir/$TCPDMUP_FILENAME", "$OUT_FOLDER/$TCPDMUP_FILENAME");
       }

       sleep(1);
       #print "Test Count = $ITERATION of $ITERATION_CNT\n";
       print "----------------------------------------------------------------\n";

       if( $TSHARK_LOG eq 1)
       {
        move("$ProgramDir/$TSHARK_FILENAME", "$OUT_FOLDER/$TSHARK_FILENAME");
       }

       #STEP 2 : SAVE QXDM       
       move("$ProgramDir/$QXDM_FILE", "$OUT_FOLDER/$QXDM_FILE");
       
       #STEP 3 : SAVE TCPDUMP
       if( $TCPDUMP_LOG eq 1)
       {
        move("$ProgramDir/$TCPDMUP_FILENAME", "$OUT_FOLDER/$TCPDMUP_FILENAME");
       }

       #chdir($ProgramDir);
   }

   $QXDM->QuitApplication(); 


   #chdir($OUT_FOLDER);
   
   open(FI, "<$CMD_OUTOUT_FILENAME"); 
   open(FO, ">$THROUGHPUT_RESULT_FILENAME");

    while($_ =<FI>)
    {
    	if( /ftp> (\d+).(\d)(\d)(\d+).(\d+)/)
    	{
     		printf FO "$1.$2$3\n";
    	}
    }
    close(FI);
    close(FO);  

    #chdir($ProgramDir);

    move("$ProgramDir/$CMD_OUTOUT_FILENAME", "$OUT_FOLDER/$CMD_OUTOUT_FILENAME");
    move("$ProgramDir/$THROUGHPUT_RESULT_FILENAME", "$OUT_FOLDER/$THROUGHPUT_RESULT_FILENAME");

    print "Finish All Testing\n";

} 
else #$ERROR_CEHCK
{
    print "STOP SCRIPT DUE TO ERROR!!\n";
}

} # Main body of script

Execute();
