import fs from 'node:fs';
import { spawn, execSync } from 'node:child_process';

let timestamp = '';
const cacheLogPathname = '/tmp/cachestat.log';

let diskOps = {
    read_ops: 0,
    write_ops: 0
  };
let interval = 0;
let waitPercent = 0;  // Add wait percentage tracking

function parseInterval(intervalStr) {
  // Parse interval like "1m0s" into seconds
  const minMatch = intervalStr.match(/(\d+)m/);
  const secMatch = intervalStr.match(/(\d+)s/);
  const minutes = minMatch ? parseInt(minMatch[1]) : 0;
  const seconds = secMatch ? parseInt(secMatch[1]) : 0;
  return minutes * 60 + seconds;
}

function parseSize(sizeStr) {
  // Convert size with suffix (G, M, K) to MB
  const match = sizeStr.match(/^([\d.]+)([GMK])?$/);
  if (!match) return 0;
  
  const value = parseFloat(match[1]);
  const suffix = match[2] || '';
  
  switch (suffix) {
    case 'G': return value * 1024;     // GB to MB
    case 'M': return value;            // Already MB
    case 'K': return value / 1024;     // KB to MB
    default:  return value / (1024 * 1024); // Bytes to MB
  }
}

function readCacheStats() {
    const cacheData = new Map();
    const cacheContent = fs.readFileSync(cacheLogPathname, 'utf-8');
    const lines = cacheContent.split('\n');

    // Skip header                                                                                                                                    
    for (let i = 1; i < lines.length; i++) {
        const line = lines[i].trim();
        if (line) {
            const [timestamp, hits, misses] = line.split(/\s+/);
            cacheData.set(timestamp, parseInt(misses, 10));
        }
    }
    return cacheData;
}

function processAtopLogs(logFile, appName, volumeName, intendedInterval, beginTime = null, endTime = null) {
  console.log('timestamp,app,cpu_percent,wait_percent,read_iops,write_iops,read_MBps,write_MBps,cache_misses');
  const cacheStats = readCacheStats();      // Build atop command arguments
  const atopArgs = ['-r', logFile];
  // atop args are just HH:MM
  if (beginTime) atopArgs.push('-b', beginTime.slice(0, 5));
  if (endTime) atopArgs.push('-e', endTime.slice(0,5));
  // console.log("spawn atop", atopArgs);
  const atop = spawn('atop', atopArgs);
  let buffer = '';
  let sampleTime = null;
    
  atop.stdout.on('data', (data) => {
    buffer += data.toString();
    processBuffer();
  });

  function processBuffer() {
    const lines = buffer.split('\n');
    let skipUntilNextHeader = false;
    buffer = lines.pop(); // Keep partial line for next chunk


    for (const line of lines) {
      // Extract timestamp and interval from ATOP header
      if (line.startsWith('ATOP')) {
        // Parse "ATOP - hostname    YYYY/MM/DD  HH:MM:SS      interval elapsed"
        const matches = line.match(/ATOP - \S+\s+(\d{4}\/\d{2}\/\d{2})\s+(\d{2}:\d{2}:\d{2})\s+(.+?elapsed)/);
        if (matches) {
          const [_, date, time, intervalStr] = matches;
          // Convert to ISO8601
          sampleTime = time;
          timestamp = `${date.replace(/\//g, '-')}T${time}`;
          interval = parseInterval(intervalStr);
          //console.log('line:', line, 'timestamp: ', timestamp, 'interval: ', interval);
          // Reset disk stats for new interval
          diskOps = {
            read_ops: 0,
            write_ops: 0
          };
          waitPercent = 0;  // Reset wait percentage
          // console.log("process_atop_logs: ", "beginTime", beginTime, "endTime", endTime, "v/s time", time);
        }
        continue;
      }

      // Extract CPU wait percentage from global CPU line
      if (line.startsWith('CPU |')) {
        const waitMatch = line.match(/wait\s+(\d+)%/);
        if (waitMatch) {
          waitPercent = parseInt(waitMatch[1]);
        }
      }

      // Extract disk operations
      if (line.startsWith('DSK |')) {
        const fields = line.split('|').map(f => f.trim());
        // console.log('DSK fields: ', fields);
        if (fields[1] === volumeName) {
          const matches = line.match(/DSK \|.*\|\s*read\s+(\d+)\s*\|\s*write\s+(\d+)\s*\|/);
          // console.log('DSK matches: ', matches);
          if (matches && interval > 0) {
            diskOps.read_ops = parseInt(matches[1]);
            diskOps.write_ops = parseInt(matches[2]);
          }
        }
        // console.log('fields: ', fields, timestamp, interval, diskOps);
      }

      // Process application stats
      /* the application line is
    PID SYSCPU USRCPU  VGROW  RGROW  RDDSK  WRDSK S CPUNR  CPU CMD            
1029842  0.16s  3.20s     0K     0K      -      - E     -   6% <munin-graph>        */
	if (line.includes(appName) && !line.includes('<')) {
        // console.log(line);
        const fields = line.split(/\s+/).filter(f => f.length > 0);
        //console.log('app fields: ', fields, timestamp, interval, diskOps);
            // Fields[2] is SYSCPU, Fields[3] is USRCPU
            // console.log("process_atop_logs: app:", "beginTime", beginTime, "endTime", endTime, "v/s sampleTime", sampleTime, (sampleTime >= beginTime), (sampleTime <= endTime));
          if (fields.length >= 8 && sampleTime &&
              (!beginTime || (sampleTime >= beginTime)) &&
	          (!endTime || (sampleTime <= endTime))) {
            // Get CPU percentage directly from the field before app name
            const cpuPercent = parseFloat(fields[fields.length - 2]);
            if (cpuPercent > 0) {
              // Parse read/write bytes from application fields
              const readBytes = parseSize(fields[5]);
              const writeBytes = parseSize(fields[6]);
              //console.log('readBytes: ', fields[5], readBytes, 'writeBytes: ', fields[6], writeBytes);
              if (timestamp && interval > 0) {
                const cacheMisses = cacheStats.get(timestamp) || 0;
                const read_MBps = Math.round(readBytes / interval);
                const write_MBps = Math.round(writeBytes / interval);
                console.log(`${timestamp},${appName},${cpuPercent.toFixed(2)},${waitPercent},${Math.round(diskOps.read_ops/interval)},${Math.round(diskOps.write_ops/interval)},${read_MBps},${write_MBps},${cacheMisses}`);
              }
            }
          }
        }
    }
  }

  atop.stderr.on('data', (data) => {
    console.error(`Error: ${data}`);
  });

  atop.on('close', (code) => {
    if (code !== 0) {
      console.error(`atop process exited with code ${code}`);
    }
  });
}

// Parse command line arguments
const args = process.argv.slice(2);
if (args.length < 4) {
  console.error('Usage: node process_atop_logs.js <logfile> <appname> <volumename> <interval> [-b HH:MM] [-e HH:MM]');
  process.exit(1);
}

const logFile = args[0];
const appName = args[1];
const volumeName = args[2];
const intendedInterval = args[3] + 's';
let beginTime = null;
let endTime = null;
//console.log('logFile: ', logFile, 'appName: ', appName, 'volumeName: ', volumeName);
// Parse optional time arguments
for (let i = 4; i < args.length; i += 2) {
  if (args[i] === '-b') beginTime = args[i + 1];
  if (args[i] === '-e') endTime = args[i + 1];
}
// console.log("process_atop_logs", 'appName: ', appName, 'beginTime: ', beginTime, 'endTime: ', endTime);
processAtopLogs(logFile, appName, volumeName, intendedInterval, beginTime, endTime); 
