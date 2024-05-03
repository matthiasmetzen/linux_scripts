set -eu

pids=()

(sleep 3; echo ok3) &
pids+=($!)

(sleep 2; echo fail2; exit 1) &
pids+=($!)

(sleep 1; echo ok1) &
pids+=($!)

for pid in "${pids[@]}"; do
  if wait -n; then
    :
  else
    status=$?
    echo "One of the subprocesses exited with nonzero status $status. Aborting."
    for pid in "${pids[@]}"; do
      # Send a termination signal to all the children, and ignore errors
      # due to children that no longer exist.
      kill "$pid" 2> /dev/null || :
    done
    exit "$status"
  fi
done
