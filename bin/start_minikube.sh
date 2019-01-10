minikube profile serverless_datascience


minikube start \
	 --memory=8192 \
	 --cpus=4 \
	 --disk-size=30GB \
	 --kubernetes-version=v1.11.0 \
	 --insecure-registry="10.0.0.0/24" \
	 --profile serverless_datascience

minikube mount $(pwd):/mnt &

eval $(minikube docker-env)
