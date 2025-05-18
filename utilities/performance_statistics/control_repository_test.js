import fs from 'node:fs';
import { spawn, execSync } from 'node:child_process';
import path from 'node:path';
import * as d3 from 'd3';
import { JSDOM } from 'jsdom';
const applicationName = 'spocq';

// If you need __filename and __dirname in ES modules:
//const __filename = fileURLToPath(import.meta.url);
//const __dirname = dirname(__filename);

function getCleanName(repoPath) {
    // Convert full pathname to a safe filename
    // e.g., "/path/to/repo" becomes "path_to_repo"
    return repoPath.replace(/^\//, '').replace(/[\/\s<>:"|?*]/g, '_');
}

async function setAtopInterval(seconds) {
    try {
        execSync(`sudo systemctl stop atop`);
        execSync(`sudo sed -i 's/LOGINTERVAL=[0-9]*/LOGINTERVAL=${seconds}/' /usr/share/atop/atop.daily`);
        execSync(`sudo systemctl start atop`);
        console.log(`Set atop interval to ${seconds} seconds`);
    } catch (error) {
        console.error('Error modifying atop interval:', error);
        throw error;
    }
}

async function flushRepositoryCache(repoName) {
    try {
        // Get repository database path
        const repoDir = execSync(`/opt/rails/script/repository_path ${repoName}`, { encoding: 'utf8' }).trim();
        const dbPath = `${repoDir}/data.mdb`;
        
        console.log(`Flushing cache for database: ${dbPath}`);
        execSync(`vmtouch -e ${dbPath}`);
        console.log('Cache flush completed');
    } catch (error) {
        console.error('Error flushing repository cache:', error);
        throw error;
    }
}

async function runTestAndProcess(repoName, interval) {
    const cleanName = getCleanName(repoName);
    const today = new Date().toISOString().split('T')[0].replace(/-/g, '');
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const outputDir = `test_results_${timestamp}`;
    const testOutputPath = `/tmp/test_${cleanName}_${today}.csv`;
    
    try {
        // Create output directory
        fs.mkdirSync(outputDir, { recursive: true });
        console.log(`Created output directory: ${outputDir}`);

        // Run test-spo.sh with shell execution and output path
        console.log(`Running test-spo.sh for ${repoName}`);
        await new Promise((resolve, reject) => {
            const test = spawn('sh', ['run-test.sh', repoName, testOutputPath], {
                stdio: 'inherit'
            });
            test.on('error', (err) => {
                reject(new Error(`Failed to start test-spo.sh: ${err.message}`));
            });
            test.on('close', (code) => {
                if (code === 0) resolve();
                else reject(new Error(`test-spo.sh failed with code ${code}`));
            });
        });

        // Process results with output directory
        console.log('Processing test results');
        await new Promise((resolve, reject) => {
            const process = spawn('node', [
                'extend_query_stats.js',
                testOutputPath,
                'spocq',
                'nvme2n1',
                interval,
                outputDir
            ], {
                stdio: ['ignore', 'inherit', 'pipe']
            });

            let errorOutput = '';
            process.stderr.on('data', (data) => {
                errorOutput += data.toString();
            });

            process.on('close', (code) => {
                if (code === 0) {
                    resolve();
                } else {
                    reject(new Error(`extend_query_stats.js failed with code ${code}\nError output: ${errorOutput}`));
                }
            });
        });

        console.log('Generating graphs');
        await new Promise((resolve, reject) => {
            const process = spawn('node', [
                //'generate_graphs.js',
                'generate_graph_grid.js',
                repoName,
                outputDir
            ], {
                stdio: ['ignore', 'inherit', 'pipe']
            });

            let errorOutput = '';
            process.stderr.on('data', (data) => {
                errorOutput += data.toString();
            });

            process.on('close', (code) => {
                if (code === 0) {
                    resolve();
                } else {
                    reject(new Error(`generate_graphs.js failed with code ${code}\nError output: ${errorOutput}`));
                }
            });
        });
        return outputDir;
    } catch (error) {
        console.error('Error in test execution:', error);
        throw error;
    }
}



async function main() {
    if (process.argv.length < 4) {
        console.error('Usage: node control_repository_test.js <repository_name> <interval>');
        process.exit(1);
    }

    const repoName = process.argv[2];
    const interval = process.argv[3];
    console.log('repoName: ', repoName, 'interval: ', interval);
    
    try {
        // Flush repository cache first
        await flushRepositoryCache(repoName);

        // Set 5-second interval
        await setAtopInterval(interval);

        // Run test and process results
        const outputFile = await runTestAndProcess(repoName, interval);
        console.log(`Generated performance graphs in ${outputFile}`);

        // Reset to 60-second interval
        await setAtopInterval(60);
    } catch (error) {
        console.error('Test execution failed:', error);
        await setAtopInterval(60); // Ensure we reset interval even on failure
        process.exit(1);
    }
}

main(); 