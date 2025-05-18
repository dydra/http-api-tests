import fs from 'node:fs';
import { execSync } from 'node:child_process';
import path from 'node:path';
import * as d3 from 'd3';
import { JSDOM } from 'jsdom';

function getCleanName(repoPath) {
    return repoPath.replace(/^\//, '').replace(/[\/\s<>:"|?*]/g, '_');
}

function generateGraphGrid(repoName, cleanName, outputDir) {
    const hostname = execSync('hostname', { encoding: 'utf8' }).trim();
    const dom = new JSDOM('<!DOCTYPE html><html><body></body></html>');

    // Read and group CSV files by result count
    const csvFiles = fs.readdirSync(outputDir).filter(f => f.startsWith('query_'));
    if (csvFiles.length === 0) {
        throw new Error(`No performance data files found in ${outputDir}`);
    }

    // Group files by result count
    const fileGroups = new Map();
    console.log("csvfiles", csvFiles);
    csvFiles.forEach(file => {
        const countMatch = file.match(/query_.*?_(\d+)\.csv$/);
        const timeMatch = file.match(/query_(\d{8})(\d{6})_/);
        if (countMatch && timeMatch) {
            const resultCount = parseInt(countMatch[1]);
            if (!fileGroups.has(resultCount)) {
                fileGroups.set(resultCount, []);
            }
            fileGroups.set(resultCount, [...fileGroups.get(resultCount), {
                file,
                timestamp: `${timeMatch[1]}T${timeMatch[2]}`,
                count: resultCount
            }]);
        }
    });

    // Sort groups by result count and sort files within groups by timestamp
    const sortedGroups = Array.from(fileGroups.entries())
        .sort(([count1], [count2]) => count1 - count2)
        .map(([count, files]) => ({
            count,
            files: files.sort((a, b) => a.timestamp.localeCompare(b.timestamp))
        }));
    console.log("sortedGroups", sortedGroups);

    const margin = { top: 40, right: 100, bottom: 50, left: 60 };
    const width = 600 - margin.left - margin.right;  // Smaller width for grid layout
    const height = 300 - margin.top - margin.bottom; // Smaller height for grid layout

    const html = `
<!DOCTYPE html>
<html>
<head>
    <title>Performance Metrics Grid for ${repoName} on ${hostname}</title>
    <script src="https://d3js.org/d3.v7.min.js"></script>
    <style>
        .grid-container {
            display: flex;
            flex-direction: row;
            gap: 20px;
            padding: 20px;
        }
        .column {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
        .graph-container {
            border: 1px solid #ccc;
            padding: 10px;
        }
        .line { fill: none; stroke-width: 2; }
        .read { stroke: blue; }
        .write { stroke: green; }
        .wait { stroke: red; }
        .cache-misses { stroke: purple; }
        .axis-label { font-size: 12px; }
        .graph-title { font-size: 14px; font-weight: bold; text-align: center; margin-bottom: 10px; }
    </style>
</head>
<body>
    <h1>Performance Metrics Grid for ${repoName} on ${hostname}</h1>
    <div class="grid-container">
    ${sortedGroups.map(group => `
        <div class="column">
            <h2>${group.count.toLocaleString()} Results</h2>
            ${group.files.map((fileInfo, index) => {
                const data = processFile(`${outputDir}/${fileInfo.file}`);
                if (!data || data.length === 0) return '';
                
                // Calculate relative timestamps
                const startTime = data[0].timestamp;
                const relativeData = data.map(d => ({
                    ...d,
                    relativeTime: (d.timestamp - startTime) / 1000 // seconds from start
                }));

                return generateGraphHtml(fileInfo, relativeData, index, width, height, margin);
            }).join('\n')}
        </div>
    `).join('\n')}
    </div>
</body>
</html>`;

    const outputFile = `${outputDir}/performance_grid_${hostname}_${cleanName}_${new Date().toISOString().split('T')[0]}.html`;
    fs.writeFileSync(outputFile, html);
    return outputFile;
}

function processFile(filePath) {
    const content = fs.readFileSync(filePath, 'utf-8');
    const lines = content.split('\n');
    const data = [];
    
    for (let i = 1; i < lines.length; i++) {
        const line = lines[i].trim();
        if (line) {
            const [timestamp, app, cpu, wait, read_iops, write_iops, read_MB, write_MB, cache_misses] = line.split(',');
            const dataPoint = {
                timestamp: new Date(timestamp).getTime(),
                read_MB: Number(read_MB),
                write_MB: Number(write_MB),
                wait: Number(wait),
                cache_misses: Number(cache_misses)
            };
            if (!isNaN(dataPoint.timestamp)) {
                data.push(dataPoint);
            }
        }
    }
    return data.sort((a, b) => a.timestamp - b.timestamp);
}

function generateGraphHtml(fileInfo, data, index, width, height, margin) {
    return `
    <div class="graph-container">
        <div class="graph-title">Test at ${fileInfo.timestamp}</div>
        <div id="graph_${fileInfo.count}_${index}"></div>
    </div>
    <script>
    (function() {
        const data = ${JSON.stringify(data)};
        
        const svg = d3.select("#graph_${fileInfo.count}_${index}")
            .append("svg")
            .attr("width", ${width + margin.left + margin.right})
            .attr("height", ${height + margin.top + margin.bottom})
            .append("g")
            .attr("transform", \`translate(\${${margin.left}},\${${margin.top}})\`);

        const x = d3.scaleLinear()
            .domain([0, d3.max(data, d => d.relativeTime)])
            .range([0, ${width}]);

        const yIO = d3.scaleLinear()
            .domain([0, d3.max(data, d => Math.max(d.read_MB, d.write_MB)) * 1.1])
            .range([${height}, 0]);

        const yWait = d3.scaleLinear()
            .domain([0, 100])
            .range([${height}, 0]);

        const yCacheMisses = d3.scaleLinear()
            .domain([0, d3.max(data, d => d.cache_misses)])
            .range([${height}, 0]);

        // Add lines
        svg.append("path")
            .datum(data)
            .attr("class", "line read")
            .attr("d", d3.line()
                .x(d => x(d.relativeTime))
                .y(d => yIO(d.read_MB)));

        svg.append("path")
            .datum(data)
            .attr("class", "line write")
            .attr("d", d3.line()
                .x(d => x(d.relativeTime))
                .y(d => yIO(d.write_MB)));

        svg.append("path")
            .datum(data)
            .attr("class", "line wait")
            .attr("d", d3.line()
                .x(d => x(d.relativeTime))
                .y(d => yWait(d.wait)));

        svg.append("path")
            .datum(data)
            .attr("class", "line cache-misses")
            .attr("d", d3.line()
                .x(d => x(d.relativeTime))
                .y(d => yCacheMisses(d.cache_misses)));

        // Add axes
        const xAxis = d3.axisBottom(x)
            .tickFormat(d => \`\${Math.floor(d/60)}m \${Math.floor(d%60)}s\`);
        
        svg.append("g")
            .attr("transform", \`translate(0,\${${height}})\`)
            .call(xAxis);

        svg.append("g")
            .call(d3.axisLeft(yIO));

        svg.append("g")
            .attr("transform", \`translate(\${${width}},0)\`)
            .call(d3.axisRight(yWait));

        svg.append("g")
            .attr("transform", \`translate(\${${width} + 40},0)\`)
            .call(d3.axisRight(yCacheMisses));

        // Add legend
        const legend = svg.append("g")
            .attr("font-size", 10)
            .attr("text-anchor", "start")
            .selectAll("g")
            .data(["Read MB/s", "Write MB/s", "Wait %", "Cache Misses"])
            .enter().append("g")
            .attr("transform", (d, i) => \`translate(\${${width} - 80},\${i * 20 - 30})\`);

        legend.append("rect")
            .attr("width", 15)
            .attr("height", 15)
            .attr("fill", (d, i) => ["blue", "green", "red", "purple"][i]);

        legend.append("text")
            .attr("x", 20)
            .attr("y", 12)
            .text(d => d);
    })();
    </script>`;
}

// Main execution
const args = process.argv.slice(2);
if (args.length < 2) {
    console.error('Usage: node generate_graph_grid.js <repository_name> <result_directory>');
    process.exit(1);
}

const repoName = args[0];
const outputDir = args[1];

if (!fs.existsSync(outputDir)) {
    console.error(`Output directory does not exist: ${outputDir}`);
    process.exit(1);
}

const cleanName = getCleanName(repoName);

try {
    generateGraphGrid(repoName, cleanName, outputDir);
    console.log('Graph grid generation completed successfully');
} catch (error) {
    console.error('Error generating graph grid:', error.message);
    process.exit(1);
} 
