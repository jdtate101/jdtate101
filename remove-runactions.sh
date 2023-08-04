actions=$(kubectl get runactions | awk '{print $1}')
for actions in $actions; do
  kubectl delete runaction $actions
done
