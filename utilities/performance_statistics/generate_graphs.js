import fs from 'node:fs';
import { spawn, execSync } from 'node:child_process';
import path from 'node:path';
import * as d3 from 'd3';
import { JSDOM } from 'jsdom';

function getCleanName(repoPath) {
    // Convert full pathname to a safe filename
    // e.g., "/path/to/repo" becomes "path_to_repo"
    return repoPath.replace(/^\//, '').replace(/[\/\s<>:"|?*]/g, '_');
}

function generateGraphs(repoName, cleanName, outputDir) {
    const hostname = execSync('hostname', { encoding: 'utf8' }).trim();
    const dom = new JSDOM('<!DOCTYPE html><html><body></body></html>');
    const document = dom.window.document;

    // Read CSV files from the output directory
    const csvFiles = fs.readdirSync(outputDir).filter(f => f.startsWith('query_'));
    console.log(`Found CSV files in ${outputDir}:`, csvFiles);
    
    // Add error handling for no CSV files
    if (csvFiles.length === 0) {
        console.error(`No query CSV files found in directory: ${outputDir}`);
        throw new Error(`No performance data files found in ${outputDir}`);
    }
    
    // Process each file separately
    const allGraphsData = csvFiles.map(file => {
        // Updated regex patterns to match actual file format
        const countMatch = file.match(/query_.*?_(\d+)\.csv$/);
        const timeMatch = file.match(/query_(\d{8})(\d{6})_/);
        
        if (!countMatch || !timeMatch) {
            console.error(`Unable to parse filename: ${file}`);
            return null;
        }

        const resultCount = parseInt(countMatch[1]).toLocaleString();
        const timestamp = `${timeMatch[1]}T${timeMatch[2]}`; // YYYYMMDDTHHMMSS format
        
        const data = [];
        const content = fs.readFileSync(`${outputDir}/${file}`, 'utf-8');
        const lines = content.split('\n');
        
        for (let i = 1; i < lines.length; i++) {
            const line = lines[i].trim();
            if (line) {
                const [timestamp, app, cpu, wait, read_iops, write_iops, read_MB, write_MB, cache_misses] = line.split(',');
                const dataPoint = {
                    timestamp: new Date(timestamp),
                    read_MB: Number(read_MB),
                    write_MB: Number(write_MB),
                    wait: Number(wait),
                    cache_misses: Number(cache_misses)
                };
                if (!isNaN(dataPoint.timestamp.getTime())) {
                    data.push(dataPoint);
                }
            }
        }
        
        return {
            resultCount,
            timestamp,
            serializedData: data.sort((a, b) => a.timestamp - b.timestamp)
                .map(point => ({
                    timestamp: point.timestamp.toISOString(),
                    read_MB: point.read_MB,
                    write_MB: point.write_MB,
                    wait: point.wait,
                    cache_misses: point.cache_misses
                }))
        };
    }).filter(Boolean); // Remove any null entries from failed parsing

    // Add error handling for no valid data after processing
    if (allGraphsData.length === 0) {
        console.error(`No valid data found in CSV files in directory: ${outputDir}`);
        throw new Error(`No valid performance data found in ${outputDir}`);
    }

    const margin = { top: 40, right: 100, bottom: 50, left: 60 };
    const width = 800 - margin.left - margin.right;
    const height = 400 - margin.top - margin.bottom;

    const html = `
<!DOCTYPE html>
<html>
<head>
    <title>Performance Metrics for ${repoName} on ${hostname}</title>
    <script src="https://d3js.org/d3.v7.min.js"></script>
    <style>
        .graph-container { margin-bottom: 40px; }
        .line { fill: none; stroke-width: 2; }
        .read { stroke: blue; }
        .write { stroke: green; }
        .wait { stroke: red; }
        .axis-label { font-size: 12px; }
        .graph-title { font-size: 14px; font-weight: bold; text-align: center; margin-bottom: 10px; }
        .cache-misses-axis { color: purple; }
    </style>
</head>
<body>
    <h1>Performance Metrics for ${repoName} on ${hostname}</h1>
    ${allGraphsData.map((graphData, index) => `
    <div class="graph-container">
        <div class="graph-title">Query on ${hostname} for ${repoName} at ${graphData.timestamp} (${graphData.resultCount} results)</div>
        <div id="graph${index}"></div>
    </div>
    <script>
    (function() {
        const data = ${JSON.stringify(graphData.serializedData)};
        data.forEach(d => d.timestamp = new Date(d.timestamp));

        const margin = ${JSON.stringify(margin)};
        const width = ${width};
        const height = ${height};

        const svg = d3.select("#graph${index}")
            .append("svg")
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform", \`translate(\${margin.left},\${margin.top})\`);

        const x = d3.scaleTime()
            .domain(d3.extent(data, d => d.timestamp))
            .range([0, width]);

        // Left Y axis for IO rates
        const yIO = d3.scaleLinear()
            .domain([0, d3.max(data, d => Math.max(d.read_MB, d.write_MB)) * 1.1])
            .range([height, 0]);

        // Right Y axis for wait percentage (inner right)
        const yWait = d3.scaleLinear()
            .domain([0, 100])  // Wait is a percentage
            .range([height, 0]);

        // Right Y axis for cache misses (outer right)
        const cacheMissesScale = d3.scaleLinear()
            .domain([0, d3.max(data, d => d.cache_misses)])
            .range([height, 0]);

        // Add IO rate lines
        svg.append("path")
            .datum(data)
            .attr("class", "line read")
            .attr("d", d3.line()
                .x(d => x(d.timestamp))
                .y(d => yIO(d.read_MB)));

        svg.append("path")
            .datum(data)
            .attr("class", "line write")
            .attr("d", d3.line()
                .x(d => x(d.timestamp))
                .y(d => yIO(d.write_MB)));

        // Add wait percentage line
        svg.append("path")
            .datum(data)
            .attr("class", "line wait")
            .attr("d", d3.line()
                .x(d => x(d.timestamp))
                .y(d => yWait(d.wait)));

        // Add axes - modify the right-side axes placement
        svg.append("g")
            .attr("transform", \`translate(0,\${height})\`)
            .call(d3.axisBottom(x));

        svg.append("g")
            .call(d3.axisLeft(yIO));

        // Inner right axis (wait percentage)
        svg.append("g")
            .attr("transform", \`translate(\${width},0)\`)
            .call(d3.axisRight(yWait));

        // Outer right axis (cache misses)
        svg.append("g")
            .attr("class", "cache-misses-axis")
            .attr("transform", \`translate(\${width + 40},0)\`)  // Offset by 40px
            .call(d3.axisRight(cacheMissesScale));

        // Add axis labels - update positions
        svg.append("text")
            .attr("class", "axis-label")
            .attr("x", -height/2)
            .attr("y", -40)
            .attr("transform", "rotate(-90)")
            .style("text-anchor", "middle")
            .text("MB/s");

        svg.append("text")
            .attr("class", "axis-label")
            .attr("x", height/2)
            .attr("y", -width - 5)  // Adjust position for inner right axis
            .attr("transform", "rotate(90)")
            .style("text-anchor", "middle")
            .text("Wait %");

        svg.append("text")
            .attr("class", "axis-label")
            .attr("x", height/2)
            .attr("y", -width - 45)  // Adjust position for outer right axis
            .attr("transform", "rotate(90)")
            .style("text-anchor", "middle")
            .text("Cache Misses");

        // Add legend
        const legend = svg.append("g")
            .attr("font-family", "sans-serif")
            .attr("font-size", 10)
            .attr("text-anchor", "start")
            .selectAll("g")
            .data(["Read MB/s", "Write MB/s", "Wait %"])
            .enter().append("g")
            .attr("transform", (d, i) => \`translate(\${width - 100},\${i * 20})\`);

        legend.append("rect")
            .attr("width", 19)
            .attr("height", 19)
            .attr("fill", (d, i) => ["blue", "green", "red"][i]);

        legend.append("text")
            .attr("x", 24)
            .attr("y", 9.5)
            .attr("dy", "0.32em")
            .text(d => d);

        // Add cache misses legend entry separately
        const cacheMissesLegend = svg.append("g")
            .attr("font-family", "sans-serif")
            .attr("font-size", 10)
            .attr("text-anchor", "start")
            .attr("transform", \`translate(\${width - 100},\${3 * 20})\`);

        cacheMissesLegend.append("rect")
            .attr("width", 19)
            .attr("height", 19)
            .attr("fill", "purple");

        cacheMissesLegend.append("text")
            .attr("x", 24)
            .attr("y", 9.5)
            .attr("dy", "0.32em")
            .text("Cache Misses");

        // Add cache misses line                                                                                                                      
        const cacheMissesLine = d3.line()
            .x(d => x(d.timestamp))
            .y(d => cacheMissesScale(d.cache_misses));

        svg.append("path")
            .datum(data)
            .attr("fill", "none")
            .attr("stroke", "purple")
            .attr("stroke-width", 1.5)
            .attr("d", cacheMissesLine);

    })();
    </script>`).join('\n')}
</body>
</html>`;

    const outputFile = `${outputDir}/performance_${hostname}_${cleanName}_${new Date().toISOString().split('T')[0]}.html`;
    fs.writeFileSync(outputFile, html);
    return outputFile;
}

// Update the main execution to handle errors
const args = process.argv.slice(2);
if (args.length < 2) {
    console.error('Usage: node generate_graphs.js <repository_name> <result_directory>');
    process.exit(1);
}

const repoName = args[0];
const outputDir = args[1];

// Add directory existence check
if (!fs.existsSync(outputDir)) {
    console.error(`Output directory does not exist: ${outputDir}`);
    process.exit(1);
}

const cleanName = getCleanName(repoName);

try {
    generateGraphs(repoName, cleanName, outputDir);
    console.log('Graph generation completed successfully');
} catch (error) {
    console.error('Error generating graphs:', error.message);
    process.exit(1);
}

