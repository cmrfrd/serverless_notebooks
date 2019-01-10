## Apply users
echo "Applying user ..."
kubectl apply -f ./sample-admin-user.yml

## Get user token secret
echo "Getting user token secret ..."
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}') -o yml
