# An Efficient Test with Automatic FIT Test Script

During the FIT (Field Interoperability Test), the tester sometimes should capture the various kind of logs such as QXDM, ADB TCP dump and Wireshark data log to analyze issue. Also the saving of all logs for each count is required to compare two logs and discover the differences or similarities between a low and high performance throughput. We have conducted the test and log capturing manually until now. The introduced AFTS (Automatic FIT Test Script) software in this paper is very useful toolbox to do test and save logs automatically. The AFTS automatically connects to FTP server and start download/upload (=get/put) file. At the same time, the AFTS captures the various kind of logs what tester needs for each test count. This automatic script can make tester free without user activity and eliminates inappropriate log capturing and leads the way to capture the various kind of logs properly. In addition, the test result file will be created automatically and this is very useful when put the time to FIT workbook. The below flow-chart helps you to understand this program. In the below flow-chart, AFTS covers the most of test procedure, from ‘Make Folder’ to ‘Test Result Text File’ in the below chart. The only thing you have to do is ‘Input Parameter’ which is described in the chapter ‘Guide to Test’.

![image](https://user-images.githubusercontent.com/77954837/114701710-1df4c800-9d5e-11eb-80d0-bbc22e2d9b16.png)

## Guide to Test - Execute to Test
- Execute AFTS.pl     
There are two ways to execute the test script. One is type ‘perl AFTS.pl’ on DOS console or simple double click AFTS.pl file.
- Fill and Answer about some questions  
(Q1) Type Comport number:
(A1) Please type QXDM port number (Please refer to Step 4)
(Q2) Type tshark interface number:
(A2) Please type Wireshark port number (Please refer to Step 4)
(Q3) Type Mode Name:
(A3) Please type your device name. For example, I415, MHS291, VK410, VS880 and so on.
(Q4) Type your special test condition (if not, just Type normal or Press Enter) :
(A4) Please type the test condition. For example, normal, power-up, position_reverse and so on. You can also press Enter key if you do not want type special condition.
(Q5) Select Location (1:Dallas, 2:Irvine, 3:LGTestBed, 4:ftp.lgmobilecomm.com) :
(A5) Type 1 or 2. 1 is for Dallas LTE FTP server and 2 is for Irvine LTE FTP server.
(Q6) Select Band (1:Band13, 2:Band4) :
(A6) Type 1 or 2. 1 is for LTE Band 13 and 2 is for LTE Band 4.
(Q7) Select UTM or MHS (1:UTM, 2:MHS, 3:SVLTE) :
(A7) Type 1, 2 or 3. 1 is for USB Tethered mode, 2 is for Mobile HotSpot mode and 3 is for SVLTE mode.
(Q8) Select Download or Upload (1:Download, 2:Upload) :
(A8) Type 1 or 2. 1 is for Download test and 2 is for Upload test
(Q9) Type Start Count:
(A9) Please type the count number of starting test. You would normally type 1 as starting count.
(Q10) Type End Count:
(A10) Please type the count number of ending test. You would normally type 15 as ending count.
(Q11) Do you want tcpdump log? (1:Yes, 2:No) :
(A11) Type 1 or 2. For case of 1, ADB TCP dump log will be saved on your PC. 
(Q12) Do you want tshark log? (1:Yes, 2:No) :
(A12) Type 1 or 2. For case of 1, Wireshark log will be saved on your PC. (Please refer to Step 4 and Q2)

Example: Band 13 UTM Download Testing in Dallas market.
![image](https://user-images.githubusercontent.com/77954837/114701852-50062a00-9d5e-11eb-88b9-266cb989c5dc.png)

- After all test are finished as you put the count (End Count A10 – Start Count A9), all logs and test results are saved in one folder which is created as following the above your answers. The rule of making the folder name is “Location(A5)_Band(A6)_Mode(A7)_Test(A8)_Model_Name(A3)_Special_Condition(A4)”. 

Example : Band 13 UTM Download Testing in Irvine market.
![image](https://user-images.githubusercontent.com/77954837/114701977-7330d980-9d5e-11eb-90b4-848527306ba0.png)
The file with the extension of _qxdm.isf is QXDM modem log.
The file with the extension of _tcpdump.pcap is ADB TCP dump log.
The file with the extension of _tshark.pcap is Wireshark data log.

In this folder, there are two text files. One is the saved DOS console output text, named as “folder_name_CMD_start#_end#.txt”. The other is the test result with marked in second unit, named as “folder_name_TR_start#_end#.txt”.  The test result file is very useful when put the time to FIT workbook.
