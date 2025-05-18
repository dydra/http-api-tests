import fs from 'node:fs';
import path from 'node:path';
import { spawn } from 'node:child_process';
import { parse } from 'csv-parse';
import { fileURLToPath } from 'node:url';
import { dirname } from 'node:path';

// If you need __filename and __dirname in ES modules:
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

function convertToLocalTime(zuluTime) {
    // Convert YYYYMMDDTHHMMSSZ format to local time HH:MM
    const date = new Date(zuluTime.replace(/(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})Z/, '$1-$2-$3T$4:$5:$6Z'));
    return date.toTimeString().slice(0, 8);
}
function convertToISOString(timestamp) {
    return timestamp.replace(/^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})Z$/, '$1-$2-$3T$4:$5:$6Z');
}

function getAtopLogPath(date) {
    // Convert YYYYMMDDTHHMMSSZ to YYYY/MM/DD for atop log path
    const match = date.match(/(\d{4})(\d{2})(\d{2})/);
    return `/var/log/atop/atop_${match[1]}${match[2]}${match[3]}`;
}

function processQueryStats(queryStatsFile, appName, volumeName, intendedInterval,  outputDir) {
    fs.createReadStream(queryStatsFile)
        .pipe(parse({ columns: true, delimiter: ',' }))
        .on('data', (row) => {
	    // console.log("row", row);
            const count = row.count;
            const rowStartTime = row.start_time;
            const rowEndTime = row.end_time;

            const isoStartTime = convertToISOString(rowStartTime);
            const isoEndTime = convertToISOString(rowEndTime);
            // console.log('isoStartTime: ', isoStartTime, 'isoEndTime: ', isoEndTime);
            const adjustedStartTime = new Date(new Date(isoStartTime).getTime()).toISOString();
            const adjustedEndTime = new Date(new Date(isoEndTime).getTime()).toISOString();
        
    const atopLog = getAtopLogPath(rowStartTime);
    const beginTimeLocal = convertToLocalTime(adjustedStartTime);
    const endTimeLocal = convertToLocalTime(adjustedEndTime);

            // Create output filename based on timestamp and count
            const timestamp = rowStartTime.replace(/(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})Z/, '$1$2$3$4$5$6');
            const outFile = `${outputDir}/query_${timestamp}_${count}.csv`;
        
            
            // Spawn process_atop_logs.js with appropriate arguments
            // console.log('atopLog: ', atopLog, 'appName: ', appName, 'volumeName: ', volumeName, 'beginTime: ', beginTimeLocal, 'endTime: ', endTimeLocal);
            const proc = spawn('node', [
                'process_atop_logs.js',
                atopLog,
                appName,
                volumeName,
                intendedInterval,
                '-b', beginTimeLocal,
                '-e', endTimeLocal
            ], {
                stdio: ['ignore', 'pipe', 'inherit']
            });

            // Create write stream for output file
            const outputStream = fs.createWriteStream(outFile);
            
            // Pipe process output to file
            proc.stdout.pipe(outputStream);
            
            proc.on('close', (code) => {
                if (code !== 0) {
                    console.error(`process_atop_logs.js failed for ${rowStartTime}-${rowEndTime}`);
                }
                outputStream.end();
            });
        })
        .on('error', (error) => {
            console.error('Error processing query stats:', error);
        });
}

// Parse command line arguments
const args = process.argv.slice(2);
if (args.length < 4) {
    console.error('Usage: node extend_query_stats.js <query_stats_file> <appname> <volumename> <output_dir>');
    process.exit(1);
}

const queryStatsFile = args[0];
const appName = args[1];
const volumeName = args[2];
const interval = args[3];
const outputDir = args[4];

processQueryStats(queryStatsFile, appName, volumeName, interval, outputDir); 
