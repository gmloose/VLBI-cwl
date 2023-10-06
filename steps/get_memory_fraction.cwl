cwlVersion: v1.2
class: CommandLineTool
label: Get fraction of memory
doc: |
    Queries the available amount of memory on the system,
    and computes the given fraction of it in mebibytes (MiB).
    This is used to ensure that flagging jobs don't exceed the
    node's resources.

baseCommand:
    - python3
    - query_memory.py

stdout: memory.txt

inputs:
    - id: fraction
      type: int 
      doc: |
        The required fraction of the node's
        available memory for a flagging job.

outputs:
    - id: memory
      type: int 
      doc: |
        The fraction of the node's memory in
        mebibytes (MiB).
      outputBinding:
        glob: memory.txt
        loadContents: true
        outputEval: $(JSON.parse(self[0].contents))

requirements:
    - class: InlineJavascriptRequirement
    - class: InitialWorkDirRequirement
      listing:
        - entryname: query_memory.py
          entry: |
            import psutil
            # psuitil outputs the memory in bytes.
            # This is converted into mebibytes (1 MiB = 2^20 B)
            # to match CWL's ResourceRequirement input.
            required_memory = int(psutil.virtual_memory().available / 2**20
                                    * $(inputs.fraction) / 100)
            print(required_memory)
