# Fortify Sample C++ Demo

This sample demonstrates a simple dataflow vulnerability in C++ code. The code in sample.cpp is intended to be a simple shell program; it reads user input, 
checks that the user is running a safe program, and runs that program. However, if the user specified a command such as "safe_program ; dangerous_program", 
then the dangerous program would be executed by the system() call.
 
Fortify SCA results should contain vulnerabilities with the following categories:
   * Command Injection
   * Memory Leak
   * Other vulnerabilities might also be found depending on the versions of Rulepacks used in the scan.
 
The Command Injection vulnerability indicates that user input comes from a call to getline() on line 16 and is then passed to argument
0 of the system() call on line 21. This is due to the absence of appropriate input length checks.

### To run the scan:

First clean up any existing data from a previous build and scan:

```
sourceanalyzer -b sample-cpp -clean
msbuild ALL_BUILD.vcxproj -t:Clean
```

Next, translate the source files by prepending the sourceanalyzer command:

```
sourceanalyzer -b sample-cpp msbuild ALL_BUILD.vcxproj
```

Then, execute the scan on the translated files:

```
sourceanalyzer -b sample-cpp -scan -verbose -f sample-cpp.fpr
```

Finally, view the results in AuditWorkbench:

```
auditworkbench sample-cpp.fpr
```
