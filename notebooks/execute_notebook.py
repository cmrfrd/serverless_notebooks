import os,sys,json,logging,papermill

## Disable papermill logger
## to read stdout without logs
logger = logging.getLogger('papermill')
logger.disabled=True

## Read stdin as json to transform into paramaters
## Get return type for notebook from 'Http_Accept' header
st = sys.stdin.read()
paramaters = json.loads("".join(st)) if st!="" \
             else json.loads("{}")
notebook_return_type = os.environ['Http_Accept'].split(",")[0]

## Execute notebook from environment variable notebook paths
## Pass in stdin as json dict and disable all output
papermill.execute_notebook(
    os.environ["PLACEHOLDER_NOTEBOOK"],
    os.environ["OUTPUT_NOTEBOOK"],
    paramaters,
    progress_bar=False,
    log_output=False,
    report_mode=False
)

## Get all the cell outputs from notebook
## iterate backwards and retrieve output that
## meets 'Http_Accept' header, if none match 
## return last output
##
## If 'Http_Accept' is */* default to stdout
output_notebook = papermill.read_notebook(os.environ["OUTPUT_NOTEBOOK"])
outputs=sum([list(c["outputs"]) \
             if "outputs" in c.keys() else [] \
             for c in output_notebook.node.cells],[])

for cell in outputs[::-1]:
    if (cell["output_type"] == "error"):
        print (cell["traceback"])
        break

    elif (cell["output_type"] == "stream") and \
         ((notebook_return_type == "*/*") or \
          (notebook_return_type == "")):
        print (cell["text"])
        break
        
    elif (cell["output_type"] in ["display_data","execute_result"]):
        if (notebook_return_type in cell["data"].keys()):
            print (cell["data"][notebook_return_type])
            break
else:
    print ("No output with type %s found"%notebook_return_type)