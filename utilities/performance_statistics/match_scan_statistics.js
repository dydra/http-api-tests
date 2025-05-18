import fs from 'node:fs';
import readline from 'node:readline';

// Check arguments
if (process.argv.length < 4) {
    console.error('Usage: node match_scan_statistics.js <syslog_file> <output_file> [start_time] [end_time]');
    process.exit(1);
}

const syslogFile = process.argv[2];
const outputFile = process.argv[3];
const startTime = process.argv[4] ? new Date(process.argv[4]) : null;
const endTime = process.argv[5] ? new Date(process.argv[5]) : null;

async function processLog() {
    const fileStream = fs.createReadStream(syslogFile);
    const rl = readline.createInterface({
        input: fileStream,
        crlfDelay: Infinity
    });

    // Create a map to store statistics per repository
    const repoStats = new Map();

    for await (const line of rl) {
        if (line.includes('[statistics]')) {
            // Extract timestamp
            const timestampMatch = line.match(/^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})/);
            if (!timestampMatch) continue;
            
            const timestamp = new Date(timestampMatch[1]);
            
            // Check time range if specified
            if (startTime && timestamp < startTime) continue;
            if (endTime && timestamp > endTime) return;

            // Extract repository name
            const urlMatch = line.match(/<https:\/\/[^>]+\/([^>]+)\/([^>]+)>/);
	    // console.log("match", urlMatch);
            if (!urlMatch) continue;
            const repository = urlMatch[1]+ '/' + urlMatch[2];
            // console.log("repository", repository);
	    
            // Initialize repository stats if not exists
            if (!repoStats.has(repository)) {
                repoStats.set(repository, {
                    totalRequests: 0,
                    totalResponses: 0,
                    entryCount: 0
                });
            }
            
            // Extract match statistics
            const matchRequestsMatch = line.match(/:match_requests\s+(\d+)/);
            const matchResponsesMatch = line.match(/:match_responses\s+(\d+)/);
            
            if (!matchRequestsMatch || !matchResponsesMatch) continue;

            const requests = parseInt(matchRequestsMatch[1]);
            const responses = parseInt(matchResponsesMatch[1]);
            const average = requests > 0 ? responses / requests : 0;
            console.log("stats", repository, requests, responses, average);

            // Update repository stats
            const stats = repoStats.get(repository);
            stats.totalRequests += requests;
            stats.totalResponses += responses;
            stats.entryCount++;

            // Write to CSV
            const csvLine = `${timestamp.toISOString()},${repository},${requests},${responses},${average.toFixed(2)}\n`;
            fs.appendFileSync(outputFile, csvLine);
        }
    }

    // Write summary statistics to a new CSV file
    const summaryFile = outputFile.replace('.csv', '_summary.csv');
    fs.writeFileSync(summaryFile, 'repository,total_entries,total_requests,total_responses,overall_average\n');
    
    console.log('\nRepository Statistics:');
    for (const [repo, stats] of repoStats) {
        const overallAverage = stats.totalRequests > 0 ? stats.totalResponses / stats.totalRequests : 0;
        
        if (stats.totalRequests > 0) {
            // Write to summary CSV
            const summaryLine = `${repo},${stats.entryCount},${stats.totalRequests},${stats.totalResponses},${overallAverage.toFixed(2)}\n`;
            fs.appendFileSync(summaryFile, summaryLine);
            
            console.log(`\nRepository: ${repo}`);
            console.log(`Total Entries: ${stats.entryCount}`);
            console.log(`Total Match Requests: ${stats.totalRequests}`);
            console.log(`Total Match Responses: ${stats.totalResponses}`);
            console.log(`Overall Average Responses per Request: ${overallAverage.toFixed(2)}`);
        }
    }
}

try {
    if (!fs.existsSync(syslogFile)) {
        console.error(`Syslog file not found: ${syslogFile}`);
        process.exit(1);
    }
    processLog().catch(console.error);
} catch (error) {
    console.error('Error:', error);
    process.exit(1);
} 
