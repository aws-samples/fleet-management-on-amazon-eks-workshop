import boto3
import logging
import botocore.exceptions
from datetime import datetime, date
import csv
from bs4 import BeautifulSoup
import requests
import sys
import os
import subprocess
import time
import calendar
from awsglue.utils import getResolvedOptions
from botocore.exceptions import ClientError

args = getResolvedOptions(sys.argv, ["S3_BUCKET_NAME", "ARGO_CD_NAMESPACE", "QS_DASHBOARD_ACCOUNT", "QS_DASHBOARD_REGION"])
argocd_namespace= args["ARGO_CD_NAMESPACE"]
bucket_name = args["S3_BUCKET_NAME"]
eks_dashboard_qs_account = args["QS_DASHBOARD_ACCOUNT"]
eks_dashboard_qs_region = args["QS_DASHBOARD_REGION"]

EKS_KUBERNETES_RELEASE_CALENDAR_URL = "https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html#kubernetes-release-calendar"

logger = logging.getLogger()
logger.setLevel(logging.INFO)

master_session = boto3.session.Session()
regions = boto3.session.Session().get_available_regions("eks")
s3_client = master_session.client("s3")

account_id=eks_dashboard_qs_account

cluster_data = []
cluster_details = []
insights_data = []
clusters_per_region = []
consolidated_argo_projects_data = []


summary_data_filename = "eks-fleet-clusters-summary-data.csv"
cluster_data_filename = "eks-fleet-clusters-data.csv"
cluster_details_filename = "eks-fleet-clusters-details.csv"
upgrade_insights_filename = "eks-fleet-clusters-upgrade-insights.csv"
eks_kubernetes_calendar_filename = "eks-fleet-kubernetes-release-calendar.csv"
eks_support_data_filename = "eks-fleet-support-data.csv"
argo_projects_data_filename = "eks-fleet-argo-projects-data.csv"

os.environ['KUBECTL_INSTALL_DIR'] = '/tmp/kubectl'
kubectl_path = "/tmp/kubectl" 
os.environ["PATH"] += os.pathsep + kubectl_path


def generate_eks_summary_data(clusters_per_region):
    # Write the summary data to a CSV file
    with open(summary_data_filename, "w", newline="", encoding="utf-8") as summaryFile:
        fieldnames = ["Account Id", "Region", "Number of Clusters"]
        writer = csv.DictWriter(summaryFile, fieldnames=fieldnames)
        writer.writeheader()
        for row in clusters_per_region:
            writer.writerow(row)

    s3_client.upload_file(
        summary_data_filename,
        bucket_name,
        f"dashboard-datasets/{summary_data_filename}",
    )
    print(
        f"Summary file uploaded to s3://{bucket_name}/dashboard-datasets/{summary_data_filename}"
    )


def generate_eks_clusters_data(cluster_data):
    # Write EKS cluster level data to a CSV file
    with open(cluster_data_filename, "w", newline="", encoding="utf-8") as dataFile:
        fieldnames = [
            "Account Id",
            "Region",
            "Cluster Name",
            "Cluster Version",
            "Latest Version",
            "Versions Back",
        ]
        writer = csv.DictWriter(dataFile, fieldnames=fieldnames)
        writer.writeheader()
        for row in cluster_data:
            writer.writerow(row)
    s3_client.upload_file(
        cluster_data_filename,
        bucket_name,
        f"dashboard-datasets/{cluster_data_filename}",
    )
    print(
        f"Data file uploaded to s3://{bucket_name}/dashboard-datasets/{cluster_data_filename}"
    )


def generate_eks_clusters_details(cluster_details):
    # Write the cluster details to a CSV file
    with open(
        cluster_details_filename, "w", newline="", encoding="utf-8"
    ) as detailsFile:
        fieldnames = list(cluster_addon_data)
        writer = csv.DictWriter(detailsFile, fieldnames=fieldnames)
        writer.writeheader()
        for cluster in cluster_details:
            writer.writerow(cluster)

    s3_client.upload_file(
        cluster_details_filename,
        bucket_name,
        f"dashboard-datasets/{cluster_details_filename}",
    )
    print(
        f"Cluster details uploaded to s3://{bucket_name}/dashboard-datasets/{cluster_details_filename}"
    )


def generate_eks_upgrade_insights(insights_data):
    # Write Upgrade Insights data to a CSV file
    with open(
        upgrade_insights_filename, "w", newline="", encoding="utf-8"
    ) as insightsFile:
        fieldnames = [
            "Account Id",
            "Region",
            "Cluster Name",
            "Cluster Version",
            "InsightId",
            "Current API Usage",
            "API Deprecated Version",
            "API Replacement",
            "User Agent",
            "Number of Requests In Last 30Days",
            "Last Request Time",
        ]
        writer = csv.DictWriter(insightsFile, fieldnames=fieldnames)
        writer.writeheader()
        for insight in insights_data:
            writer.writerow(insight)
    s3_client.upload_file(
        upgrade_insights_filename,
        bucket_name,
        f"dashboard-datasets/{upgrade_insights_filename}",
    )
    print(
        f"EKS clusters insights data uploaded to s3://{bucket_name}/dashboard-datasets/{upgrade_insights_filename}"
    )


def generate_eks_kubernetes_release_calendar():
    # Fetch the HTML content
    releaseCalendar = requests.get(EKS_KUBERNETES_RELEASE_CALENDAR_URL)
    html_content = releaseCalendar.content

    # Parse the HTML using BeautifulSoup
    soup = BeautifulSoup(html_content, "html.parser")

    # Find the table containing the release calendar information
    table = soup.find("table")

    # Extract the table headers
    headers = [th.text.strip() for th in table.find_all("th")]

    # Extract the table rows
    data = []
    for tr in table.find_all("tr")[1:]:  # Skip the header row
        row = [td.text.strip() for td in tr.find_all("td")]
        data.append(row)

    # Write the data to a CSV file
    with open(
        eks_kubernetes_calendar_filename, "w", newline="", encoding="utf-8"
    ) as calendarFile:
        writer = csv.writer(calendarFile)
        writer.writerow(headers)
        writer.writerows(data)

    s3_client.upload_file(
        eks_kubernetes_calendar_filename,
        bucket_name,
        f"dashboard-datasets/{eks_kubernetes_calendar_filename}",
    )
    print(
        f"EKS Kubernetes Release Calendar uploaded to s3://{bucket_name}/dashboard-datasets/{eks_kubernetes_calendar_filename}"
    )


def generate_eks_support_info():
    with open(cluster_data_filename, "r") as dataFile, open(
        eks_kubernetes_calendar_filename, "r"
    ) as supportFile:
        # Create CSV readers
        reader1 = csv.DictReader(dataFile)
        reader2 = csv.DictReader(supportFile)

        # Create a dictionary to store the end of support dates
        end_of_support_dates = {
            row["Kubernetes version"]: (
                row["End of standard support"],
                row["End of extended support"],
            )
            for row in reader2
        }

        # Create a list to store the final report
        final_report = []

        # Iterate over the rows in file1
        for row in reader1:
            cluster_name = row["Cluster Name"]
            cluster_version = row["Cluster Version"]
            account = row["Account Id"]
            region = row["Region"]
            upgrades_report_s3_url = get_upgrades_report_s3_url(
                account, region, cluster_name
            )
            upgrades_report_github_url = ""

            # Check if the cluster version is in the end_of_support_dates dictionary
            if cluster_version in end_of_support_dates:
                end_of_support, end_of_extended_support = end_of_support_dates[
                    cluster_version
                ]

                # Convert the end of support dates to datetime objects
                end_of_support_date = datetime.strptime(
                    end_of_support, "%B %d, %Y"
                ).date()
                end_of_extended_support_date = datetime.strptime(
                    end_of_extended_support, "%B %d, %Y"
                ).date()

                # Check if today's date is past the end of support or end of extended support dates
                today = date.today()
                if today >= end_of_extended_support_date:
                    status = "Not Supported"
                elif (
                    today >= end_of_support_date
                    and today <= end_of_extended_support_date
                ):
                    status = "Extended Support"
                elif (
                    today <= end_of_support_date
                    and today <= end_of_extended_support_date
                ):
                    status = "Standard Support"
                else:
                    status = "Supported"

                # Add the cluster details and end of support dates to the final report
                final_report.append(
                    {
                        "Account Id": account,
                        "Region": region,
                        "Cluster Name": cluster_name,
                        "Cluster Version": cluster_version,
                        "EndOfSupportDate": end_of_support,
                        "EndOfExtendedSupportDate": end_of_extended_support,
                        "Status": status,
                        "UpgradesReport": upgrades_report_s3_url,
                        "UpgradesGitHubReport": upgrades_report_github_url,
                    }
                )
            else:
                # If the cluster version is not found in file2, add it to the final report with empty end of support dates
                final_report.append(
                    {
                        "Account Id": account,
                        "Region": region,
                        "Cluster Name": cluster_name,
                        "Cluster Version": cluster_version,
                        "EndOfSupportDate": "",
                        "EndOfExtendedSupportDate": "",
                        "Status": "Unknown",
                        "UpgradesReport": upgrades_report_s3_url,
                        "UpgradesGitHubReport": upgrades_report_github_url,
                    }
                )

    # Open a new CSV file for writing the final report
    with open(eks_support_data_filename, "w", newline="") as report_file:
        fieldnames = [
            "Account Id",
            "Region",
            "Cluster Name",
            "Cluster Version",
            "EndOfSupportDate",
            "EndOfExtendedSupportDate",
            "Status",
            "UpgradesReport",
            "UpgradesGitHubReport",
        ]
        writer = csv.DictWriter(report_file, fieldnames=fieldnames)

        # Write the header row
        writer.writeheader()

        # Write the final report rows
        writer.writerows(final_report)

    s3_client.upload_file(
        eks_support_data_filename,
        bucket_name,
        f"dashboard-datasets/{eks_support_data_filename}",
    )
    print(
        f"EKS Support Info data uploaded to s3://{bucket_name}/dashboard-datasets/{eks_support_data_filename}"
    )


def get_upgrades_report_s3_url(account, region, cluster_name):
    # Create an S3 client
    s3 = boto3.client("s3", region_name=region)
    # Construct the S3 object key
    object_key = f"ekscelerator-insights/upgrade-reports/{account}/{region}/{cluster_name}_upgrade_instructions.md"

    try:
        # Check if the S3 object exists
        s3.head_object(Bucket=bucket_name, Key=object_key)

        # Generate a pre-signed URL valid for 7 days
        s3_presigned_url = s3_client.generate_presigned_url(
            ClientMethod="get_object",
            Params={"Bucket": bucket_name, "Key": object_key},
            ExpiresIn=86400,  # 1 day in seconds
        )
        return s3_presigned_url
    except s3.exceptions.ClientError as e:
        if e.response["Error"]["Code"] == "404":
            return ""
        else:
            raise e


def generate_argo_projects_data(consolidated_argo_projects_data):
    # Write Argo projects data to CSV file
    with open(
        argo_projects_data_filename, "w", newline="", encoding="utf-8"
    ) as argoProjectsFile:
        writer = csv.writer(argoProjectsFile)
        writer.writerow(["Account Id", "Region", "Cluster Name", "Argo Application Name", "Application Repo", "Application Health", "Application Sync Status", "Operation State", "Source Type", "Last Sync", "Resource Kind", "Resource Name", "Resource Namespace", "Resource Health", "Resource Status", "Resource Version" ])
        for row in consolidated_argo_projects_data:
            writer.writerow(row)
    s3_client.upload_file(
        argo_projects_data_filename,
        bucket_name,
        f"dashboard-datasets/{argo_projects_data_filename}",
    )
    print(
        f"Argo projects data uploaded to s3://{bucket_name}/dashboard-datasets/{argo_projects_data_filename}"
    )

def set_kubeconfig(cluster, region) -> None:
    try:
        subprocess.check_call(
            [
                "aws",
                "eks",
                "update-kubeconfig",
                "--name",
                cluster,
                "--region",
                region,
                "--kubeconfig",
                "/tmp/kube-config/config",
            ],
            stdout=subprocess.DEVNULL,
        )  # nosec
        kubeconfig_path = os.path.expanduser("/tmp/kube-config/config")
        os.environ["KUBECONFIG"] = kubeconfig_path
    except subprocess.CalledProcessError as e:
        logger.error(f"Error setting KUBECONFIG: {e}")

def get_argo_app_details(cluster, account_id, region):
    set_kubeconfig(cluster, region)
    data = []
    logger.info(f"Checking for argo projects on cluster {cluster}, account {account_id} and region {region}")
    try:
        command_parts = "kubectl get applications --namespace argocd -o json | jq -r '.items[] | [.metadata.name, .spec.source.repoURL, .status.health.status, .status.sync.status, .status.operationState.phase, .status.sourceType, .status.operationState.finishedAt] + (.status.resources[] | [.kind, .name, .namespace, .health.status, .status, .version]) | join(\", \")'"     
        argo_resources = subprocess.check_output(command_parts, shell=True).decode().strip().split('\n')
        for item in argo_resources:
            app_details = item.rstrip(',').split(',')
            if len(app_details) == 13:
                app_name, repo, health, sync_status, operation_state, source_type, last_sync, resource_kind, resource_name, resource_namespace, resource_health, resource_status, resource_version = app_details
                data.append([account_id, region, cluster, app_name, repo, health, sync_status, operation_state, source_type, last_sync, resource_kind, resource_name, resource_namespace, resource_health, resource_status, resource_version])
    except subprocess.CalledProcessError:
            print(f"Warning: Argo Apps server not found in {cluster} (account: {account_id}, region: {region})")
            
    return data

def install_kubectl():
    try:
        os.makedirs("/tmp/kubectl", exist_ok=True)
        os.makedirs("/tmp/kube-config", mode=0o777, exist_ok=True)
        kubectl_url = "https://amazon-eks.s3.us-west-2.amazonaws.com/1.29.0/2024-01-04/bin/linux/amd64/kubectl"
        subprocess.check_call(["curl", "-o", "/tmp/kubectl/kubectl", kubectl_url])
        os.chmod("/tmp/kubectl/kubectl", 0o755)
        logger.info("kubectl has been installed successfully.")
    except subprocess.CalledProcessError as e:
        logger.error(f"Failed to install kubectl: {e}")
    
def refresh_qs_datasets():
    client = boto3.client('quicksight',  region_name=eks_dashboard_qs_region)
    res = client.list_data_sets(AwsAccountId=eks_dashboard_qs_account)
    
    # filter out your datasets using a prefix. All my datasets have chicago_crimes as their prefix
    datasets_ids = [summary["DataSetId"] for summary in res["DataSetSummaries"] if "eks-fleet" in summary["Name"]]
    logger.info(datasets_ids)
    ingestion_ids = []

    for dataset_id in datasets_ids:
        try:
            ingestion_id = str(calendar.timegm(time.gmtime()))
            client.create_ingestion(DataSetId=dataset_id, IngestionId=ingestion_id,
                                                 AwsAccountId=eks_dashboard_qs_account)
            logger.info(f'Creating ingestion for {dataset_id}')
            ingestion_ids.append(ingestion_id)
        except Exception as e:
            logger.error(e)
            pass

    for ingestion_id, dataset_id in zip(ingestion_ids, datasets_ids):
        while True:
            response = client.describe_ingestion(DataSetId=dataset_id,
                                                 IngestionId=ingestion_id,
                                                 AwsAccountId=eks_dashboard_qs_account)
            logger.info(f'Checking ingestion status for {dataset_id}')
            if response['Ingestion']['IngestionStatus'] in ('INITIALIZED', 'QUEUED', 'RUNNING'):
                time.sleep(30)     #change sleep time according to your dataset size
            elif response['Ingestion']['IngestionStatus'] == 'COMPLETED':
                logger.info("refresh completed. RowsIngested {0}, RowsDropped {1}, IngestionTimeInSeconds {2}, IngestionSizeInBytes {3}".format(
                    response['Ingestion']['RowInfo']['RowsIngested'],
                    response['Ingestion']['RowInfo']['RowsDropped'],
                    response['Ingestion']['IngestionTimeInSeconds'],
                    response['Ingestion']['IngestionSizeInBytes']))
                break
            else:
                logger.error("refresh failed for {0}! - status {1}".format(dataset_id, response['Ingestion']['IngestionStatus']))
                break

if __name__ == "__main__":
    # Install AWS CLI
    subprocess.run(["python", "-m", "pip", "install", "awscli==1.30.0"])

    # Uninstall existing botocore and boto3
    subprocess.run(["python", "-m", "pip", "uninstall", "-y", "botocore", "boto3"])

    # Install botocore and boto3
    subprocess.run(["python", "-m", "pip", "install", "botocore", "boto3"])

    install_kubectl()

    for region in regions:
        print(f"Scanning for EKS clusters in region {region}...")

        eks = boto3.client( "eks", region_name=region)

        try:
            clusterslist = eks.list_clusters()
        except botocore.exceptions.ClientError as e:
            if e.response["Error"]["Code"] == "AuthFailure":
                print(
                    f"Region {region} seems to be disabled for this account, skipping"
                )
                continue
        else:
            eksVersionsResponse = eks.describe_addon_versions()
            cluster_versions = set()
            for addon in eksVersionsResponse.get("addons"):
                for version_info in addon["addonVersions"]:
                    for compatibility in version_info["compatibilities"]:
                        cluster_versions.add(compatibility["clusterVersion"])

            eks_versions = sorted(cluster_versions, reverse=True)
            eks_versions_len = len(eks_versions)

            clusterslist = clusterslist["clusters"]
            print(f"Account {account_id} and clusters list {clusterslist}...")

            clusters_per_region.append(
                {
                    "Account Id": account_id,
                    "Region": region,
                    "Number of Clusters": len(clusterslist),
                }
            )

            for clusterName in clusterslist:
                argo_projects_data = get_argo_app_details(clusterName, account_id, region)
                consolidated_argo_projects_data.extend(argo_projects_data)

                instance = eks.describe_cluster(name=clusterName)
                for i in range(eks_versions_len):
                    if instance["cluster"]["version"] == eks_versions[i]:
                        versions_back = i

                cluster_data.append(
                    {
                        "Account Id": account_id,
                        "Region": region,
                        "Cluster Name": instance["cluster"]["name"],
                        "Cluster Version": instance["cluster"]["version"],
                        "Latest Version": eks_versions[0],
                        "Versions Back": versions_back,
                    }
                )

                # Create a dictionary to store addon details for the current cluster
                cluster_addon_data = {
                    "Account Id": account_id,
                    "Region": region,
                    "Cluster Name": clusterName,
                    "Cluster Version": instance["cluster"]["version"],
                }
                # Get addon details
                addons = eks.list_addons(clusterName=clusterName)["addons"]
                for addon in addons:
                    addon_name = addon
                    addon_version = eks.describe_addon(
                        clusterName=clusterName, addonName=addon_name
                    )["addon"]["addonVersion"]
                    cluster_addon_data[addon_name] = addon_version

                # Add the cluster addon data to the list
                cluster_details.append(cluster_addon_data)

                # Get Upgrade Insights information
                upgradeInsights = eks.list_insights(
                    clusterName=clusterName,
                    filter={
                        "categories": ["UPGRADE_READINESS"],
                        "statuses": ["WARNING", "ERROR", "UNKNOWN"],
                    },
                )
                insights = upgradeInsights["insights"]
                for insight in insights:
                    insight_id = insight["id"]
                    insight_response = eks.describe_insight(
                        clusterName=clusterName, id=insight_id
                    )
                    for details in (
                        insight_response.get("insight")
                        .get("categorySpecificSummary")
                        .get("deprecationDetails")
                    ):
                        if len(details.get("clientStats")):
                            # usage = details["usage"]
                            for client_stat in details["clientStats"]:
                                user_agent = client_stat["userAgent"]
                                num_requests = client_stat["numberOfRequestsLast30Days"]
                                last_request_time = client_stat["lastRequestTime"]
                                current_comp = details["usage"]
                                replacement_comp = (
                                    details.get("replacedWith")
                                    if details.get("replacedWith")
                                    else "No Suggested Replacement, possibly removed"
                                )
                                stopServingVersion = details["stopServingVersion"]
                                insights_data.append(
                                    {
                                        "Account Id": account_id,
                                        "Region": region,
                                        "Cluster Name": clusterName,
                                        "Cluster Version": instance["cluster"]["version"],
                                        "InsightId": insight_id,
                                        "Current API Usage": current_comp,
                                        "API Deprecated Version": stopServingVersion,
                                        "API Replacement": replacement_comp,
                                        "User Agent": user_agent,
                                        "Number of Requests In Last 30Days": num_requests,
                                        "Last Request Time": datetime.fromisoformat(
                                            str(last_request_time)
                                        ).strftime("%B %d, %Y %H:%M"),
                                    }
                                )

    generate_eks_summary_data(clusters_per_region)
    generate_eks_clusters_data(cluster_data)
    generate_eks_clusters_details(cluster_details)
    generate_eks_upgrade_insights(insights_data)
    generate_eks_kubernetes_release_calendar()
    generate_eks_support_info()
    generate_argo_projects_data(consolidated_argo_projects_data)
    refresh_qs_datasets()
