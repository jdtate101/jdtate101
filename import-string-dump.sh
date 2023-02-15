policies=$(kubectl get policies -n kasten-io -A | awk '{print $2}' | tail -n +2 | grep -vE 'k10-disaster-recovery-policy|k10-system-reports-policy')
for policies in $policies; do
  string=$(kubectl describe policy $policies -n kasten-io |grep "Receive String"| cut -c 7- )
  echo "Policy:" $policies $'\n'$string$'\n'
done
