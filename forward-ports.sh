sh -c '(kubectl port-forward svc/jupyter 8888:8888 & kubectl port-forward pod/jupyter 9999:9999 & kubectl port-forward -n openfaas svc/gateway-external 8080:8080 &)' 
