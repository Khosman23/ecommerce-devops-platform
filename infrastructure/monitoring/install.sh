#!/bin/bash

# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus stack
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values prometheus-values.yaml \
  --wait

# Install Grafana
helm install grafana grafana/grafana \
  --namespace monitoring \
  --values grafana-values.yaml \
  --wait

# Apply alerting rules
kubectl apply -f alerting-rules.yaml

# Apply service monitors
kubectl apply -f servicemonitor.yaml

echo "Monitoring stack installed successfully!"
echo "Access Grafana: kubectl port-forward svc/grafana -n monitoring 3000:80"
echo "Username: admin"
echo "Password: ecommerce-grafana-2024"