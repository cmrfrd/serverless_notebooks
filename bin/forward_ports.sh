sh -c '(kubectl port-forward svc/jupyter 9999:8888 & kubectl port-forward -n openfaas svc/gateway-external 8080:8080)' 
