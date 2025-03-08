import kopf
from reana_commons.k8s.api_client import current_k8s_corev1_api_client


FINALIZER_NAME = "dask.kopf.dev/logs"


# Store logs in DB (Replace this with actual DB logic)
def store_logs_in_db(pod_name, logs):
    print(f"Storing logs for {pod_name} in DB...")
    # Example: Save logs to a database


@kopf.on.create("v1", "pods", labels={"dask.org/component": ["scheduler", "worker"]})
def add_finalizer(_, name, namespace, logger, **kwargs):
    """Add a finalizer when a Dask pod is created."""
    pod = current_k8s_corev1_api_client.read_namespaced_pod(name, namespace)
    logger.info(f"Adding finalizer to pod {name}")
    pod.metadata.finalizers.append(FINALIZER_NAME)
    current_k8s_corev1_api_client.patch_namespaced_pod(
        name, namespace, {"metadata": {"finalizers": pod.metadata.finalizers}}
    )


@kopf.on.delete("v1", "pods", labels={"dask.org/component": ["scheduler", "worker"]})
def on_pod_delete(_, name, namespace, logger, **kwargs):
    """Retrieve logs before a Dask-labeled pod is deleted."""
    try:
        logger.info(f"Fetching logs for pod: {name} in namespace: {namespace}")
        log_response = current_k8s_corev1_api_client.read_namespaced_pod_log(
            name=name, namespace=namespace
        )
        store_logs_in_db(name, log_response)
    except Exception as e:
        logger.error(f"Error fetching logs for {name}: {e}")

    # Remove the finalizer so Kubernetes can delete the pod
    logger.info(f"Removing finalizer from {name}")
    patch_body = {"metadata": {"finalizers": []}}
    current_k8s_corev1_api_client.patch_namespaced_pod(name, namespace, patch_body)
