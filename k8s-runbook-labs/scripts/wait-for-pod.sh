#!/usr/bin/env bash
set -euo pipefail

# Wait for pod to be Ready or timeout
# Usage: wait-for-pod.sh <pod-name-or-selector> [namespace] [timeout-seconds]

POD_SELECTOR="${1:?Pod name or label selector required}"
NAMESPACE="${2:-default}"
TIMEOUT="${3:-300}"

echo "⏳ Waiting for pod matching '${POD_SELECTOR}' in namespace '${NAMESPACE}' (timeout: ${TIMEOUT}s)..."

if [[ "${POD_SELECTOR}" == *"="* ]]; then
  # Label selector
  SELECTOR_ARG="-l ${POD_SELECTOR}"
else
  # Pod name
  SELECTOR_ARG="${POD_SELECTOR}"
fi

START_TIME=$(date +%s)
while true; do
  # Check if pod is ready
  if kubectl wait pod ${SELECTOR_ARG} -n "${NAMESPACE}" --for=condition=Ready --timeout=5s 2>/dev/null; then
    echo "✅ Pod is Ready!"
    exit 0
  fi
  
  # Check timeout
  ELAPSED=$(($(date +%s) - START_TIME))
  if [ ${ELAPSED} -ge ${TIMEOUT} ]; then
    echo "❌ Timeout waiting for pod to be Ready"
    echo "Pod status:"
    kubectl get pods ${SELECTOR_ARG} -n "${NAMESPACE}" 2>/dev/null || echo "Pod not found"
    exit 1
  fi
  
  sleep 2
done
