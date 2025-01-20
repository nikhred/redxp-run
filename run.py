import yaml
import subprocess 
import os 
from multiprocessing import Pool

def read_yaml_file(file_path):
    with open(file_path, 'r') as file:
        data = yaml.safe_load(file)
    return data

def run_cmd(cmd):
    try:
        print(f"Executing {cmd}")
        result = subprocess.run(cmd, shell=True, check=True, text=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error while executing command: {e}")
        return None

def write_f(files, top):
    try:
        # create the output dir if it does not exists
        fdir = os.path.join("build", top)
        if not os.path.exists(fdir):
            os.makedirs(fdir)

        with open(os.path.join(fdir, "synth.f"), 'w') as f:
            for file in files:
                f.write(file + '\n')
    except Exception as e:
        print(f"Error writing to file: {e}")

file_path = 'examples/build.yaml'
data = read_yaml_file(file_path)
yaml_dir = os.path.dirname(os.path.abspath(file_path))

board = data["board"]

commands = []
for run in data["runs"]:
    top = run["top"]
    clk = run["clk"]
    output_dir = top

    absolute_paths = [os.path.join(yaml_dir, f) for f in run["files"]]

    generics = run.get('generics')
    synth_args = ""
    if(generics):
        for k,v in generics.items():
            synth_args += (f"-generic {k}={v} ")
            output_dir += f"_{k.lower()}{v}"

    write_f(absolute_paths, output_dir)

    # basic vivado command format
    cmd = f"vivado -mode batch -source vivado.tcl -tclargs -part {board} -top {top} -synth \"{synth_args}\"> build/{output_dir}/run.log" 
    commands.append(cmd)

# Create a pool with 4 worker processes
with Pool(processes=4) as pool:
  results = pool.map(run_cmd, commands)

# # Print the results
# for result in results:
#   print(result)