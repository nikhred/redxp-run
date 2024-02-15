# redxp-run
Python and tcl scripts to run synth, impl and bitstream generation using vivado. The main entry point is via the python script but the makefile and tcl scripts are also pretty straight forward. 

## Python
The `run.py` script reads the .yaml file containing the configuration for synthesis. It can be used to queue multiple runs with different generic parameters.

```
python3 run.py
```

``` yaml
tool: vivado
board: xczu7ev-ffvc1156-2-e
runs:
  - top: add2
    clk: 4.0
    files:
      - operators.sv
  - top: increment_by_n
    clk: 4.0
    files:
      - operators.sv
    generics: 
      DW: 8
      N: 8
```

## Makefile
to be implemented
```
make vivado
```

## tcl
usage: 
```
vivado.tcl [options] ...
options:
 -f value             filename - .f file or .sv file <>
 -clk value           target clock frequency <4.0>
 -part value          part number. Default = xczu7ev-ffvc1156-2-e (one of the free ZU+ boards) <xczu7ev-ffvc1156-2-e>
 -top value           name of the top module to be synthesised <>
 -synth value         generic parameters - passed directly to synth design <>
 -run value           Run Vivado with options. synth and impl for out-of-context mode synthesis and implementation. bts for bitstream generation 
 -help                Print this message
```
Example:
```
vivado -mode batch -source vivado.tcl -tclargs -top add2
```
