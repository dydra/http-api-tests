Repository Performance Testing Tools
==================================

This suite of tools measures and visualizes repository query performance using atop metrics and cache statistics.

It wraps the execution of a script, run-test.sh, which performs arbitrary actions on the repository and writes a csv record
with the start and stop iso timestamps for each iteration together with some distinguishing property.
Once the test script completes, the next phase uses the time interval limits from those test records
to filter the performance statistics from atop and cachestat to create a collection with one statistics csv per interval.
As the last phase, it uses the statistics csv files to generate time-series graphs in a single html page.

The current test (in run-test.sh) is a sequence of s-p-o queries for successively larger result sets.
They are run in order of increasing result set size and each is run repeatedly in order to see the effects of caching.
In order to improve the sample resolution, the background atop interval is reduced to one second prior to the test
and returned to sixty seconds after the conclusion.
The cachestat utility is executed with the same interval. 

Much of this was generated by chatgpt/o3.
The process is collected in performance_statistics.prompt.




System Requirements Installation
------------------------------
1. Install Node.js 20.x and npm:

   For Ubuntu/Debian:
       # Remove old versions if they exist
       sudo apt-get remove nodejs npm
       sudo apt-get autoremove

       # Install curl if not present
       sudo apt-get install curl

       # Add NodeSource repository and install Node.js 20.x
       curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
       sudo apt-get install -y nodejs

       # Verify installation
       node --version  # Should show v20.x.x
       npm --version

   For RHEL/CentOS:
       # Remove old nodejs if installed
       sudo yum remove nodejs npm

       # Download and run the NodeSource setup script
       curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -

       # Install Node.js and npm
       sudo yum install -y nodejs

2. Install atop:
   For Ubuntu/Debian:
       sudo apt-get install atop

   For RHEL/CentOS:
       sudo yum install atop

   Start and enable atop service:
       sudo systemctl enable atop
       sudo systemctl start atop

3. Install vmtouch:
   For Ubuntu/Debian:
       sudo apt-get install vmtouch

   For RHEL/CentOS:
       sudo yum install vmtouch

4. Include cachestat
   Make cachestat available from https://github.com/brendangregg/perf-tools/blob/master/fs/cachestat.
   Adjust the probes, if necessary, to gather read-only statistics.
   The respective formulations are present here as cachestat and cachestat_readonly.


Project Setup
------------
1. Initialize project and install dependencies:
       cd <installation-directory>
       npm init -y
       npm install d3 jsdom csv-parse

2. Ensure test-spo.sh is executable:
       chmod +x run-test.sh

3. Verify atop is running and collecting data:
       systemctl status atop

4. Launch cachestat in an additional terminal
       bash cachestat -t 1 | tee /tmp/cachestat.log


Usage
-----
Run the performance test with:

    node control_repository_test.js <repository-name> <atop-interval>

For example:
    node control_repository_test.js james/test

The script will:
1. Flush the repository's database cache
2. Set atop interval to specified interval
3. Run the query tests
4. Process the spocq, atop, and cachestat logs
5. Generate performance graphs
6. Reset atop interval to 60 seconds

Output
------
Results are stored in timestamped directories named 'test_results_<timestamp>':
- query_*.csv files containing detailed metrics
- cache miss data is stored in /tmp/cachestat.log
- performance_<hostname>_<repository>_<date>.html with interactive graphs

The graphs show:
- Read MB/s (blue line)
- Write MB/s (green line)
- Wait percentage (red line, right axis)

Each graph represents a different query size/iteration.

Troubleshooting
--------------
1. If permission errors occur:
   - Ensure you have sudo access for atop configuration
   - Check permissions on /opt/rails/script/repository_path
   - Verify write permissions in output directory

2. If graphs are empty:
   - Check atop log files in /var/log/atop
   - Verify process name matching ("spocq")
   - Check CSV files for valid data

3. If test fails to start:
   - Verify Node.js version: node --version
   - Check all npm packages are installed: npm list
   - Ensure test-spo.sh is executable

Notes
-----
- The test modifies atop's sampling interval temporarily
- Each test run creates a new directory to avoid mixing results
- Repository names may contain '/' characters
- Process matching uses the prefix "spocq"

For more information or troubleshooting, check the script comments
or contact the system administrator.

Installation and Usage Instructions
=================================

Requirements
-----------
- Node.js version 20.x or later
- npm (comes with Node.js)
- atop
- cachestat

Node.js Installation
------------------
For Ubuntu/Debian:
```bash
# Remove old versions if they exist
sudo apt-get remove nodejs npm
sudo apt-get autoremove

# Install curl if not present
sudo apt-get install curl

# Add NodeSource repository and install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version  # Should show v20.x.x
npm --version
```

Package Configuration
-------------------
Create a package.json file with the following configuration:
```json
{
  "name": "atop-statistics",
  "version": "1.0.0",
  "type": "module",
  "dependencies": {
    "d3": "^7.8.5",
    "jsdom": "^24.0.0"
  }
}
```

Install dependencies:
```bash
npm install
```

File Structure
-------------
Required files:
- process_atop_logs.js
- extend_query_stats.js
- control_repository_test.js
- package.json

Usage
-----
1. Run performance tests:
   ```bash
   ./run-test.sh <volume_name> <output_directory>
   ```

2. Process results:
   ```bash
   node extend_query_stats.js <volume_name> <output_directory>
   ```

Output
------
- CSV files with performance metrics
- HTML files with interactive graphs

Notes
-----
- Ensure all JavaScript files use ES module imports (import statement) rather than require()
- The package.json "type": "module" setting is required for ES module support
- Node.js 20.x is required for proper ES module support and compatibility with the dependencies
- All built-in Node.js modules should be imported with the 'node:' prefix, e.g.:
  ```javascript
  import fs from 'node:fs';
  import path from 'node:path';
  ```

Troubleshooting
--------------
1. If you see "SyntaxError: Cannot use import statement outside a module":
   - Ensure package.json has "type": "module"
   - Ensure you're using Node.js 20.x or later

2. If you see import/require related errors:
   - Check that all .js files use ES module import syntax
   - Verify that built-in modules use the 'node:' prefix 