minikube profile serverless_datascience

minikube start \
	 --memory=8192 \
	 --cpus=4 \
	 --disk-size=50GB \
	 --kubernetes-version=v1.11.0 \
	 --insecure-registry localhost:5000 \
	 --profile serverless_datascience

minikube mount $(pwd):/mnt &

eval $(minikube docker-env)
