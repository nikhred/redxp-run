import os
from tabulate import tabulate

def parse_utilisation_file(filepath):
    try:
        with open(filepath, 'r') as f:
            lines = [line.strip() for line in f.readlines()]
    except Exception as e:
        print(f"Error reading {filepath}: {e}")
        return None, None

    # Extract design name
    design_name = None
    for line in lines:
        if '| Design       :' in line:
            parts = line.split(':')
            if len(parts) >= 2:
                design_name = parts[1].strip()
                break
    if not design_name:
        return None, None

    # Locate the Utilization by Hierarchy section and the table
    table_start = None
    for i, line in enumerate(lines):
        if line.startswith('1. Utilization by Hierarchy'):
            # Look for the next occurrence of a line starting with '+'
            for j in range(i, len(lines)):
                if lines[j].startswith('+'):
                    table_start = j
                    break
            if table_start:
                break
    if not table_start:
        return None, None

    # Parse headers and rows
    header_line = None
    for j in range(table_start + 1, len(lines)):
        if '|' in lines[j]:
            header_line = lines[j]
            break
    if not header_line:
        return None, None
    headers = [cell.strip() for cell in header_line.split('|')[1:-1]]

    # Find data rows
    data_rows = []
    in_data = False
    for line in lines[table_start + 2:]:
        if line.startswith('+'):
            if in_data:
                break  # End of data rows
            else:
                in_data = True
                continue
        if in_data and '|' in line:
            row = [cell.strip() for cell in line.split('|')[1:-1]]
            data_rows.append(row)

    # Find the top instance row
    instance_col = headers.index('Instance') if 'Instance' in headers else -1
    if instance_col == -1:
        return None, None
    top_row = None
    for row in data_rows:
        if len(row) > instance_col and row[instance_col] == design_name:
            top_row = row
            break
    if not top_row:
        return None, None

    return headers, top_row

def main():
    start_dir = os.path.join(os.getcwd(),"build")  # Start from current directory, can be modified
    results = []
    table_headers = None

    for root, dirs, files in os.walk(start_dir):
        if 'utilization.txt' in files:
            filepath = os.path.join(root, 'utilization.txt')
            headers, top_row = parse_utilisation_file(filepath)
            if headers and top_row:
                if table_headers is None:
                    table_headers = ['Directory'] + headers
                results.append([os.path.basename(root)] + top_row)

    if not results:
        print("No utilization data found.")
        return

    print(tabulate(results, headers=table_headers, tablefmt='grid'))

if __name__ == "__main__":
    main()