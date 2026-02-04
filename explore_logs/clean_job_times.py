import re
import sys
import os
from datetime import datetime

def parse_time(t):
    """Parses a timestamp string into a datetime object."""
    try:
        return datetime.strptime(t, "%Y-%m-%dT%H:%M:%S")
    except ValueError:
        return None

def parse_maxrss(s):
    """Parses MaxRSS string (e.g., '2048K', '1G') into bytes."""
    s = s.strip()
    if not s or s == '0':
        return 0
    try:
        if s.endswith('K'):
            return int(float(s[:-1]) * 1024)
        elif s.endswith('M'):
            return int(float(s[:-1]) * 1024 * 1024)
        elif s.endswith('G'):
            return int(float(s[:-1]) * 1024 * 1024 * 1024)
        else:
            return int(s)
    except ValueError:
        return 0

def analyze_job_log(directory, filename):
    filepath = os.path.join(directory, filename)
    jobs = {}

    print(f"Reading log file: {filepath}")

    try:
        with open(filepath, 'r') as f:
            for line in f:
                line = line.strip()
                # Skip empty lines, headers, or separator lines
                if not line or line.startswith('JobID') or line.startswith('----'):
                    continue

                parts = re.split(r'\s+', line)

                # FIX: Require at least 5 columns (JobID, JobName, Start, End, Elapsed)
                # The input data shows MaxRSS is often missing, so we don't require 6.
                if len(parts) < 5:
                    continue

                jobid = parts[0]
                jobname = parts[1]
                start_str = parts[2]
                end_str = parts[3]
                
                # FIX: Check if MaxRSS column (index 5) exists. If not, default to '0'.
                if len(parts) >= 6:
                    maxrss_str = parts[5]
                else:
                    maxrss_str = '0'

                # Extract Parent Job ID (e.g., '21517141' from '21517141_300')
                m = re.match(r'(\d+)_', jobid)
                if not m:
                    continue
                parent = m.group(1)

                start_time = parse_time(start_str)
                end_time = parse_time(end_str)
                maxrss = parse_maxrss(maxrss_str)

                if parent not in jobs:
                    jobs[parent] = {
                        'jobname': None,
                        'start_times': [],
                        'end_times': [],
                        'maxrss': []
                    }

                # Collect valid times (skipping 'extern' usually helps avoid noise, 
                # but 'batch' is often the main allocation time)
                if jobname != 'extern':
                    if start_time:
                        jobs[parent]['start_times'].append(start_time)
                    if end_time:
                        jobs[parent]['end_times'].append(end_time)

                jobs[parent]['maxrss'].append(maxrss)

                # Capture the first meaningful job name (ignoring generic Slurm names)
                if jobs[parent]['jobname'] is None and jobname not in ('batch', 'extern'):
                    jobs[parent]['jobname'] = jobname

    except FileNotFoundError:
        print(f"Error: File not found at {filepath}")
        return
    except Exception as e:
        print(f"An error occurred: {e}")
        return

    # Write the summary output
    output_file = os.path.join(directory, 'job_times_summary.log')
    try:
        with open(output_file, 'w') as out_file:
            for pj, data in sorted(jobs.items()):
                starts = data['start_times']
                ends = data['end_times']
                maxrss_vals = data['maxrss']
                # Fallback name if only 'batch' lines were found
                jobname = data['jobname'] or "N/A"

                if not starts or not ends:
                    out_file.write(f"No valid times found for job {pj}\n")
                    continue

                earliest_start = min(starts)
                latest_end = max(ends)
                total_time = latest_end - earliest_start
                max_mem_bytes = max(maxrss_vals) if maxrss_vals else 0

                out_file.write(f"Parent Job {pj} ({jobname}):\n")
                out_file.write(f"  Earliest start: {earliest_start}\n")
                out_file.write(f"  Latest end:     {latest_end}\n")
                out_file.write(f"  Total elapsed:  {total_time}\n")
                # Format MaxRSS to MB for readability
                out_file.write(f"  Highest MaxRSS: {max_mem_bytes / (1024*1024):.2f} MB\n\n")
        
        print(f"Success! Summary written to: {output_file}")

    except Exception as e:
        print(f"Error writing output file: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 clean.py <path_to_directory> <log_filename>")
        sys.exit(1)

    path_to_dir = sys.argv[1]
    file_name = sys.argv[2]
    
    analyze_job_log(path_to_dir, file_name)
