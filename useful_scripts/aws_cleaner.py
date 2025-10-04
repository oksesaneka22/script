#!/usr/bin/env python3
import boto3
import sys
import time

def confirm():
    print("⚠️  WARNING: This will delete almost ALL AWS resources in this account (except default ones).")
    ans = input("Type 'DELETE' to continue: ")
    if ans.strip() != "DELETE":
        print("Aborted.")
        sys.exit(1)

# ----------------------- #
# EC2 / VPC Cleanup       #
# ----------------------- #
def delete_ec2_and_vpc():
    ec2 = boto3.client("ec2")

    print("Deleting Auto Scaling Groups...")
    autoscale = boto3.client("autoscaling")
    for asg in autoscale.describe_auto_scaling_groups()["AutoScalingGroups"]:
        autoscale.delete_auto_scaling_group(
            AutoScalingGroupName=asg["AutoScalingGroupName"], ForceDelete=True
        )

    print("Deleting Load Balancers...")
    elb = boto3.client("elb")
    alb = boto3.client("elbv2")
    for lb in elb.describe_load_balancers()["LoadBalancerDescriptions"]:
        elb.delete_load_balancer(LoadBalancerName=lb["LoadBalancerName"])
    for lb in alb.describe_load_balancers()["LoadBalancers"]:
        alb.delete_load_balancer(LoadBalancerArn=lb["LoadBalancerArn"])

    print("Deleting EFS file systems...")
    efs = boto3.client("efs")
    for fs in efs.describe_file_systems()["FileSystems"]:
        for mount in efs.describe_mount_targets(FileSystemId=fs["FileSystemId"])["MountTargets"]:
            efs.delete_mount_target(MountTargetId=mount["MountTargetId"])
            time.sleep(5)
        efs.delete_file_system(FileSystemId=fs["FileSystemId"])

    print("Deleting EC2 instances...")
    reservations = ec2.describe_instances()["Reservations"]
    for res in reservations:
        for inst in res["Instances"]:
            ec2.terminate_instances(InstanceIds=[inst["InstanceId"]])

    print("Deleting custom VPCs...")
    vpcs = ec2.describe_vpcs()["Vpcs"]
    for vpc in vpcs:
        if vpc.get("IsDefault"):  # skip default VPC
            continue
        vpc_id = vpc["VpcId"]

        # detach and delete IGWs
        igws = ec2.describe_internet_gateways(
            Filters=[{"Name": "attachment.vpc-id", "Values": [vpc_id]}]
        )["InternetGateways"]
        for igw in igws:
            ec2.detach_internet_gateway(InternetGatewayId=igw["InternetGatewayId"], VpcId=vpc_id)
            ec2.delete_internet_gateway(InternetGatewayId=igw["InternetGatewayId"])

        # delete subnets
        subnets = ec2.describe_subnets(Filters=[{"Name": "vpc-id", "Values": [vpc_id]}])["Subnets"]
        for sn in subnets:
            ec2.delete_subnet(SubnetId=sn["SubnetId"])

        # delete route tables
        rtbs = ec2.describe_route_tables(Filters=[{"Name": "vpc-id", "Values": [vpc_id]}])["RouteTables"]
        for rtb in rtbs:
            assoc = rtb.get("Associations", [])
            if not any(a.get("Main") for a in assoc):  # skip main
                ec2.delete_route_table(RouteTableId=rtb["RouteTableId"])

        # delete security groups
        sgs = ec2.describe_security_groups(Filters=[{"Name": "vpc-id", "Values": [vpc_id]}])["SecurityGroups"]
        for sg in sgs:
            if sg["GroupName"] != "default":
                ec2.delete_security_group(GroupId=sg["GroupId"])

        # delete VPC
        ec2.delete_vpc(VpcId=vpc_id)

# -----------------------
# EKS Cleanup
# -----------------------
def delete_eks():
    eks = boto3.client("eks")
    clusters = eks.list_clusters()["clusters"]
    for cluster in clusters:
        print(f"Deleting EKS cluster {cluster}...")
        eks.delete_cluster(name=cluster)

# -----------------------
# S3 Cleanup
# -----------------------
def delete_s3():
    s3 = boto3.resource("s3")
    for bucket in s3.buckets.all():
        print(f"Deleting S3 bucket {bucket.name}...")
        bucket.objects.all().delete()
        bucket.object_versions.all().delete()
        bucket.delete()

# -----------------------
# ACM Certificates
# -----------------------
def delete_acm():
    acm = boto3.client("acm")
    certs = acm.list_certificates()["CertificateSummaryList"]
    for cert in certs:
        print(f"Deleting ACM certificate {cert['CertificateArn']}...")
        acm.delete_certificate(CertificateArn=cert["CertificateArn"])

# -----------------------
# CloudWatch Cleanup
# -----------------------
def delete_cloudwatch():
    cw = boto3.client("cloudwatch")
    print("Deleting CloudWatch alarms...")
    alarms = cw.describe_alarms()["MetricAlarms"]
    if alarms:
        cw.delete_alarms(AlarmNames=[a["AlarmName"] for a in alarms])

    print("Deleting CloudWatch dashboards...")
    dashes = cw.list_dashboards()["DashboardEntries"]
    if dashes:
        cw.delete_dashboards(DashboardNames=[d["DashboardName"] for d in dashes])

    logs = boto3.client("logs")
    print("Deleting CloudWatch log groups...")
    for group in logs.describe_log_groups()["logGroups"]:
        logs.delete_log_group(logGroupName=group["logGroupName"])

# -----------------------
# Main
# -----------------------
def main():
    confirm()
    delete_ec2_and_vpc()
    delete_eks()
    delete_s3()
    delete_acm()
    delete_cloudwatch()
    print("✅ AWS cleanup completed (except default resources).")

if __name__ == "__main__":
    main()
